fields <- function(...) {
  that <- list(...)
  class(that) <- "fields"
  that
}

#' @exportS3Method base::as.data.frame
as.data.frame.fields <- function(x, ...) {
  data.frame(
    `Field name` = fields_names(x),
    `Description` = fields_description(x),
    `Width` = fields_widths(x),
    `Type` = purrr::map_chr(fields_handlers(x), function(y) attr(y, "type")),
    row.names = seq_along(x),
    check.names = FALSE
  )
}

#' @exportS3Method base::print
print.fields <- function(x, ...) {
  ulid <- cli::cli_ul()
  names <- fields_names(x)
  types <- sapply(fields_handlers(x), \(x) attr(x, "type"))
  desc <- fields_description(x)
  for (ix in seq_along(names)) {
    cli::cli_li("{.strong {names[ix]}} ({types[ix]}): {desc[ix]}")
  }
  cli::cli_end(ulid)
  invisible(x)
}

fields_names <- function(fields) {
  purrr::map_chr(fields, function(x) as.character(x))
}

fields_widths <- function(fields) {
  purrr::map_int(fields, function(x) as.integer(attr(x, "width")))
}

fields_description <- function(fields) {
  purrr::map_chr(fields, function(x) as.character(attr(x, "description")))
}

fields_handlers <- function(fields) {
  handlers <- lapply(fields, function(x) attr(x, "handler"))
  names(handlers) <- fields_names(fields)
  handlers
}

fields_cols <- function(fields) {
  handlers <- lapply(fields, function(x) attr(x, "col"))
  names(handlers) <- fields_names(fields)
  handlers
}

fields_arrow_types <- function(fields) {
  handlers <- lapply(fields, function(x) attr(x, "arrow"))
  names(handlers) <- fields_names(fields)
  handlers
}

fields_tags <- function(fields) {
  handlers <- lapply(fields, function(x) attr(x, "tag"))
  names(handlers) <- fields_names(fields)
  handlers
}

field <- function(name, description, ...) {
  if (missing(description)) {
    attr(name, "description") <- ""
    parms <- list(...)
  } else {
    if (inherits(description, "character")) {
      attr(name, "description") <- description
      parms <- list(...)
    } else {
      attr(name, "description") <- ""
      parms <- list(description, ...)
      cli::cli_warn("description invalid type: {paste(class(description), collapse = ', ')}")
    }
  }

  classes <- lapply(parms, function(x) {
    if (inherits(x, "width")) {
      "width"
    } else if (inherits(x, "tag")) {
      "tag"
    } else if (inherits(x, "handler")) {
      "handler"
    } else if (inherits(x, "collector")) {
      "col"
    } else if (inherits(x, "DataType") && inherits(x, "ArrowObject")) {
      "arrow"
    } else {
      NULL
    }
  })

  if (any(classes == "width")) {
    attr(name, "width") <- parms[[which(classes == "width")[1]]]
  } else {
    attr(name, "width") <- 0
  }

  if (any(classes == "tag")) {
    attr(name, "tag") <- parms[[which(classes == "tag")[1]]]
  }

  if (any(classes == "handler")) {
    attr(name, "handler") <- parms[[which(classes == "handler")[1]]]
  } else {
    attr(name, "handler") <- pass_thru_handler()
  }

  if (any(classes == "col")) {
    attr(name, "col") <- parms[[which(classes == "col")[1]]]
  } else {
    attr(name, "col") <- readr::col_guess()
  }

  if (any(classes == "arrow")) {
    attr(name, "arrow") <- parms[[which(classes == "arrow")[1]]]
  } else {
    attr(name, "arrow") <- arrow::string()
  }

  class(name) <- "field"
  name
}

#' @exportS3Method base::print
print.parts <- function(x, ...) {
  nx <- names(x)
  for (ix in seq_along(nx)) {
    dx <- dim(x[[ix]])
    cat(sprintf(
      "Part %2d: %s [%d obs. of %d variables]", ix, nx[ix], dx[1],
      dx[2]
    ), "\n")
  }
}
