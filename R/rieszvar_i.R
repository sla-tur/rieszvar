rieszvar_i <- function(y, x, k, q) {
  
  system.file("src", "sperner_families_omp.c", package = "rieszvar")
  generate_sperner_families <- function(n, k) {
    .Call("generate_sperner_families", as.integer(n), as.integer(k))
  }
  
  if(!is.vector(y)) {
    print("Error: Y not a vector. Attempt to vectorify.")
    y <- as.vector(y)
  }
  
  if(!is.matrix(x) && !is.vector(x)) {
    print("Warning: X not a matrix, attempting matrix conversion.")
    if(is.vector(x) && !is.integer(length(x) %% length(y))){
      print("Matrix incompatible with Y. Aborting.")
      stop()
    }
    x <- as.matrix(x, nrows = length(y))
  }
  
  if(nrow(x) != length(y) && length(x) != length(y)) {
    print("Error: Y and X incompatible.")
    stop()
  }
  
  # Number of observations
  n <- length(y)
  
  generate_grid_with_cells <- function(x, k) {
    if (is.vector(x)) {
      n <- length(x)
      cell_size <- floor(n / k)
      # Vector sorted ascending
      sorted_x <- sort(x)
      
      cells <- vector("list", k)
      grid_boundaries <- numeric(k + 1)
      
      for (i in 1:k) {
        start <- (i - 1) * cell_size + 1
        if (i == k) {
          end <- n
        } else {
          end <- i * cell_size
        }
        grid_boundaries[i] <- sorted_x[start]
        if (i == k) {
          grid_boundaries[i + 1] <- sorted_x[end]
        }
        cells[[i]] <- sorted_x[start:end]
      }
      
      return(list(grid_boundaries = grid_boundaries, cells = cells))
      
    } else if (is.matrix(x)) {  #
      n <- nrow(x)
      cell_size <- floor(n / k)
      # Sort by first column of matrix
      sorted_x <- x[order(x[, 1]), ]
      
      cells <- vector("list", k)
      grid_boundaries <- numeric(k + 1)
      
      for (i in 1:k) {
        start <- (i - 1) * cell_size + 1
        if (i == k) {
          end <- n
        } else {
          end <- i * cell_size
        }
        
        grid_boundaries[i] <- sorted_x[start, 1]
        if (i == k) {
          grid_boundaries[i + 1] <- sorted_x[end, 1]
        }
        cells[[i]] <- sorted_x[start:end, , drop = FALSE]
      }
      
      return(list(grid_boundaries = grid_boundaries, cells = cells))
    }
  }
  
  ols_estimate <- function(x, y, k) {
    grid_cells <- generate_grid_with_cells(x, k)
    ols_estimates <- vector("list", k)
    
    if (is.vector(x)) {
      for (i in 1:k) {
        # Retrieve the observations in current cell 
        cell_x <- grid_cells$cells[[i]]
        cell_y <- y[x >= min(cell_x) & x <= max(cell_x)]
        # Run OLS on the cell's observations
        ols_estimates[[i]] <- as.vector(stats::lm(cell_y ~ cell_x)$coefficients)
      }
    } else if (is.matrix(x)) {
      for (i in 1:k) {
        cell_rows <- which(apply(matrix(x %in% grid_cells$cells[[i]], ncol = ncol(x)), 1, all))
        cell_x <- x[cell_rows, ]
        cell_y <- y[cell_rows]
        ols_estimates[[i]] <- as.vector(stats::lm(cell_y ~ cell_x)$coefficients)
      }
    }
    
    return(ols_estimates)
  }
  
  # Run OLS on each of the k regions and store coefficients in list
  cell_ols <- ols_estimate(x, y, k)
  Ej <- generate_sperner_families(k, q)
  # Regressor matrix
  regmat <- cbind(1, x)
  # Create list to store prediction vectors
  sse <- list()
  minima <- list()
  
  # Loop over each Sperner family in Ej
  for (i in seq_along(Ej)) {  
    sperner_family <- Ej[[i]]  # Each Sperner family is a list of indices
    minima_matrix <- matrix(Inf, nrow = nrow(regmat), ncol = length(sperner_family))  # Initialize for minima
    
    # Second loop over each set in the Sperner family
    for (j in seq_along(sperner_family)) {  
      set_members <- sperner_family[[j]]  # Get members of the Sperner family set
      
      # Initialize a matrix to store results for each member of the set
      ej_reg_set <- matrix(NA, nrow = nrow(regmat), ncol = length(set_members))  # Stores results for each member
      
      # Third internal loop over the members of each set in the Sperner family
      for (m in seq_along(set_members)) {
        index <- set_members[m]  # Get the index for the OLS coefficients
        
        # Perform matrix multiplication for the current member
        ols_coeffs <- cell_ols[[index]]
        if (length(ols_coeffs) == ncol(regmat)) {
          ej_reg_set[, m] <- regmat %*% ols_coeffs  # Store the predicted values for each member
        } else {
          stop(paste("Dimension mismatch at index", index))
        }
      }
      
      # After processing all members, calculate the minimum for each row across members of this set
      minima_matrix[, j] <- apply(ej_reg_set, 1, min)  # Min across members of this set
    }
    
    # Once we have the minima for each set, take the max across sets
    pred <- apply(minima_matrix, 1, max)  # Max across sets (sup-inf structure)
    
    # Calculate SSE for this Sperner family
    sse[[i]] <- sum((y - pred)^2)
  }
  
  # Now find the Sperner family that minimizes the SSE across the entire vector
  best_sse <- Inf
  best_family <- NULL
  
  # Iterate over each Sperner family to calculate the SSE for the entire vector
  for (i in seq_along(sse)) {
    pred <- sse[[i]]  # Minima for this family
    current_sse <- sum((y - pred)^2)  # Calculate SSE for this family
    
    # Check if this is the best SSE
    if (current_sse < best_sse) {
      best_sse <- current_sse  # Update best SSE
      best_family <- i  # Store the index of the best Sperner family
    }
  }
  
  # Output the results
  names(cell_ols) <- paste0("f", 1:length(cell_ols))
  print(cell_ols)
  print(paste("Best Sum of Squared Errors:", best_sse))
  print(paste("Best Sperner Family:", best_family))
  print("Corresponding Sets in the Best Sperner Family:")
  print(Ej[[best_family]])
  
  # Simple functional form display
  best_sperner_family <- Ej[[best_family]]
  functional_form <- ""
  
  for (j in seq_along(best_sperner_family)) {
    set_members <- best_sperner_family[[j]]
    set_function <- paste0("f", set_members, collapse = " ^ ")  # Combine members with '^'
    
    # Functional form for this set
    if (j == 1) {
      functional_form <- set_function  # No maximum, just use minimum
    } else {
      functional_form <- paste0("(", functional_form, ") v (", set_function, ")")  # Combine with 'v'
    }
  }
  print(paste("The model that minimizes the error is: f =", functional_form))
}