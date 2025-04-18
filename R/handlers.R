tag <- function(x) {
  class(x) <- c("character", "tag")
  x
}

width <- function(x) {
  x <- as.numeric(x)
  class(x) <- c("numeric", "width")
  x
}

to_date_handler <- function(format = NULL) {
  if (is.null(format)) {
    format <- "%Y-%m-%d"
  }
  handler <- function(x) {
    as.Date(x, format = format)
  }
  attr(handler, "format") <- format
  attr(handler, "type") <- "Date"
  class(handler) <- c("function", "handler")
  handler
}

to_time_handler <- function(format = NULL) {
  if (is.null(format)) {
    format <- "%H:%M:%S"
  }
  handler <- function(x) {
    strptime(x, format = format)
  }
  attr(handler, "format") <- format
  attr(handler, "type") <- "POSIXct"
  class(handler) <- c("function", "handler")
  handler
}

to_factor_handler <- function(levels = NULL, labels = levels) {
  handler <- function(x) {
    if (is.null(levels)) {
      factor(x)
    } else {
      factor(x, levels = levels, labels = labels)
    }
  }
  attr(handler, "levels") <- levels
  attr(handler, "labels") <- labels
  attr(handler, "type") <- "factor"
  class(handler) <- c("function", "handler")
  handler
}

to_numeric_handler <- function(dec = 0, sign = "") {
  handler <- function(x) {
    if (inherits(dec, "character")) {
      dec <- get(dec, envir = parent.frame())
    }
    if (!sign %in% c("+", "-", "")) {
      sign <- get(sign, envir = parent.frame())
    }
    x <- paste0(sign, x)
    as.numeric(x) / (10^as.numeric(dec))
  }
  attr(handler, "dec") <- dec
  attr(handler, "sign") <- sign
  attr(handler, "type") <- "numeric"
  class(handler) <- c("function", "handler")
  handler
}

pass_thru_handler <- function() {
  handler <- identity
  attr(handler, "type") <- "character"
  class(handler) <- c("function", "handler")
  handler
}

to_strtime_handler <- function(format = NULL, tz = NULL) {
  if (is.null(format)) {
    format <- "%H%M%OS"
  }
  if (is.null(tz)) {
    tz <- "GMT"
  }
  handler <- function(x) {
    z <- str_pad(x, 9, pad = "0") |> str_match("(\\d{6})(\\d{3})")
    t <- str_c(z[, 2], ".", z[, 3])
    strptime(t, format = format, tz = tz)
  }
  attr(handler, "format") <- format
  attr(handler, "type") <- "strtime"
  class(handler) <- c("function", "handler")
  handler
}
