create_registry <- function() {
  # Private instance variable
  instance <- NULL

  # Constructor function
  create <- function() {
    # Create a new object if no instance exists
    if (is.null(instance)) {
      new_instance <- list(
        data = list(),
        created_at = Sys.time(),
        .p = environment(create)
      )
      # Set class for S3 dispatch
      class(new_instance) <- "registry"
      # Store instance in enclosing environment
      instance <<- new_instance
    }
    instance
  }

  # Return the constructor
  list(get_instance = create)
}

print.registry <- function(x, ...) {
  cat("registry instance created at:", format(x$created_at), "\n")
  cat("# elements", length(x$data), "\n")
  invisible(x)
}

registry_get <- function(x, ...) {
  x$data
}

registry_put <- function(x, key, value, ...) {
  x$data[[key]] <- value
  x$.p[["instance"]] <- x
  invisible(x)
}

registry_keys <- function(x, ...) {
  names(x$data)
}

# Usage example
singleton <- create_singleton()
instance1 <- singleton$get_instance()
instance1 <- set_data(instance1, "name", "Hello, world!")
instance1
instance2 <- singleton$get_instance()
instance2
instance2 <- set_data(instance2, "name", "Wilson")
singleton$get_instance()
instance2$data
