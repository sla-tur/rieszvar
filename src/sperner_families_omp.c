#include <R.h>
#include <Rinternals.h>
#include <stdlib.h>
#include <omp.h>

#define MAX_ELEMENTS 32 // 32-bit integer for bitmasking

// Function to check if a family of subsets is an antichain using bitwise operations
static inline int is_antichain(unsigned int *family, int family_size) {
  for (int i = 0; i < family_size - 1; i++) {
    for (int j = i + 1; j < family_size; j++) {
      // Check if family[i] is a subset of family[j] or vice versa
      if ((family[i] & family[j]) == family[i] || (family[i] & family[j]) == family[j]) {
        return 0; // Not an antichain
      }
    }
  }
  return 1; // It's an antichain
}

// Function to count the number of set bits in an integer (i.e., the size of the subset)
static inline int count_set_bits(unsigned int x) {
  int count = 0;
  while (x) {
    count += x & 1;
    x >>= 1;
  }
  return count;
}

// Function to convert a bitmask to the actual subset elements
SEXP bitmask_to_elements(unsigned int bitmask, int n) {
  int element_count = count_set_bits(bitmask);
  SEXP result = PROTECT(allocVector(INTSXP, element_count));
  int idx = 0;
  for (int i = 0; i < n; i++) {
    if (bitmask & (1u << i)) {
      INTEGER(result)[idx++] = i + 1; // Convert 0-indexed bit position to 1-indexed element
    }
  }
  UNPROTECT(1);
  return result;
}

// Optimized function to generate Sperner families with union size <= k, using parallelization
SEXP generate_sperner_families(SEXP r_n, SEXP r_k) {
  int n = asInteger(r_n); // Number of elements in the set
  int k = asInteger(r_k); // Maximum size of the union of subsets in the Sperner family

  if (n > MAX_ELEMENTS) {
    error("The number of elements cannot exceed %d", MAX_ELEMENTS);
  }

  unsigned int *subsets = malloc((1u << n) * sizeof(unsigned int)); // Array to store subsets as bitmasks
  int subset_count = 0;

  // Generate all subsets as bitmasks, but limit the size to subsets with <= k elements
  for (unsigned int i = 1; i < (1u << n); i++) {
    if (count_set_bits(i) <= k) {
      subsets[subset_count++] = i; // Store only subsets with <= k elements
    }
  }

  // Pre-allocate an R list to store the results (Sperner families)
  int initial_capacity = 100;
  SEXP result_list = PROTECT(allocVector(VECSXP, initial_capacity));
  int result_list_size = 0;

  // Allocate memory for family to avoid reallocating inside parallel loop
  unsigned int *family = malloc(subset_count * sizeof(unsigned int));

  // Parallelize the iteration through all combinations of subsets using OpenMP
#pragma omp parallel for schedule(dynamic)
  for (int i = 1; i < (1u << subset_count); i++) {
    int family_size = 0;
    unsigned int union_set = 0;

    // Construct the current family from the binary representation of i
    for (int j = 0; j < subset_count; j++) {
      if (i & (1u << j)) {
        family[family_size++] = subsets[j];
        union_set |= subsets[j]; // Bitwise union of all subsets in the family
      }
    }

    // Check if the union of the family has <= k elements
    if (count_set_bits(union_set) <= k && is_antichain(family, family_size)) {
      // Protecting shared resources
#pragma omp critical
{
  // Store the current Sperner family as a list of subsets
  SEXP family_list = PROTECT(allocVector(VECSXP, family_size));
  for (int j = 0; j < family_size; j++) {
    SET_VECTOR_ELT(family_list, j, bitmask_to_elements(family[j], n));
  }

  // Add the family list to the result list
  if (result_list_size >= initial_capacity) {
    initial_capacity *= 2;  // Double the capacity if needed
    result_list = PROTECT(lengthgets(result_list, initial_capacity));
    UNPROTECT(1);  // Unprotect the previous result_list
  }
  SET_VECTOR_ELT(result_list, result_list_size++, family_list);
  UNPROTECT(1); // Unprotect family_list
}
    }
  }

  // Trim result_list to the correct size
  if (result_list_size < initial_capacity) {
    result_list = PROTECT(lengthgets(result_list, result_list_size));
  }

  free(family);   // Free allocated memory for the family array
  free(subsets);  // Free allocated memory for the subsets array

  UNPROTECT(2); // Unprotect result_list
  return result_list;
}

// Register the function for use in R
static const R_CallMethodDef CallEntries[] = {
  {"generate_sperner_families", (DL_FUNC) &generate_sperner_families, 2},
  {NULL, NULL, 0}
};

void R_init_rieszvar(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
