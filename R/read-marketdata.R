#' Read and parse raw market data files downloaded from the B3 website.
#'
#' @description
#' B3 provides various files containing valuable information about
#' traded assets on the exchange and over-the-counter (OTC) market.
#' These files include historical market data, trading data, and asset registration
#' data for stocks, derivatives, and indices. This function reads these
#' files and parses their content according to the specifications
#' defined in a template.
#'
#' @param meta A list containing the downloaded file's metadata, typically returned by \code{\link{download_marketdata}}.
#'
#' @details
#' This function reads the downloaded file and parses its content according
#' to the specifications and schema defined in the template associated with the `meta` object.
#' The template specifies the file format, column definitions, and data types.
#'
#' The parsed data is then written to a partitioned dataset in Parquet format,
#' stored in a directory structure based on the template name and data layer.
#' This directory is located within the `db` subdirectory of the `rb3.cachedir` directory.
#' The partitioning scheme is also defined in the template, allowing for efficient
#' querying of the data using the `arrow` package.
#'
#' If an error occurs during file processing, the function issues a warning,
#' removes the downloaded file and its metadata, and returns `NULL`.
#'
#' @return This function invisibly returns the parsed `data.frame` if successful, or `NULL` if an error occurred.
#'
#' @seealso \code{\link{list_templates}}
#' @seealso \code{\link{rb3.cachedir}}
#' @seealso \code{\link{download_marketdata}}
#'
#' @examples
#' \dontrun{
#' meta <- download_marketdata("b3-cotahist-daily", refdate = as.Date("2024-04-05"))
#' read_marketdata(meta)
#' }
#' 
#' @export
read_marketdata <- function(meta) {
  filename <- meta$downloaded[[1]]
  template <- template_retrieve(meta$template)
  df <- template$read_file(template, filename)
  if (is.null(df)) {
    cli_alert_warning("File could not be read: {.file {filename}}")
    meta_clean(meta)
    return(invisible(NULL))
  }
  for (writer in template$writers) {
    ds <- writer$process_marketdata(df)
    path <- template_db_folder(template, layer = writer$layer)
    ds <- arrow::arrow_table(ds, schema = template_schema(template, writer$layer))
    arrow::write_dataset(ds, path, partitioning = writer$partition)
  }
  invisible(df)
}


#' Fetch and process market data
#'
#' Downloads market data based on a template and parameter combinations, then reads
#' the data into a database.
#'
#' @param template A character string specifying the market data template to use
#' @param ... Named arguments that will be expanded into a grid of all combinations
#'   to fetch data for
#'
#' @details
#' This function performs two main steps:
#' 1. Downloads market data files by creating all combinations of the provided parameters
#'    and calling `download_marketdata()` for each combination
#' 2. Processes the downloaded files by reading them into a database using `read_marketdata()`
#'
#' Progress indicators are displayed during both steps, and warnings are shown for
#' combinations that failed to download or produced invalid files.
#'
#' @examples
#' \dontrun{
#' fetch_marketdata("b3-cotahist-yearly", year = 2020:2024)
#' fetch_marketdata("b3-cotahist-daily", refdate = bizseq("2025-01-01", "2025-03-10", "Brazil/B3"))
#' fetch_marketdata("b3-reference-rates", refdate = bizseq("2025-01-01", "2025-03-10", "Brazil/B3"),
#'   curve_name = c("DIC", "DOC", "PRE")
#' )
#' }
#'
#' @export
fetch_marketdata <- function(template, ...) {
  df <- expand.grid(...)
  cli::cli_h1("Fetching market data for {.var {template}}")
  # ----
  pb <- cli::cli_progress_step("Downloading data", spinner = TRUE)
  ms <- purrr::pmap(df, function(...) {
    cli::cli_progress_update(id = pb)
    row <- list(...)
    m <- do.call(download_marketdata, c(template, row))
    if (is.null(m)) {
      msg <- paste(names(row), row, sep = " = ", collapse = ", ")
      cli::cli_alert_warning("No data downloaded for args {.val {msg}}")
    }
    m
  })
  cli::cli_process_done(id = pb)
  # ----
  pb <- cli::cli_progress_step("Reading data into DB", spinner = TRUE)
  purrr::map(ms, function(m) {
    cli::cli_progress_update(id = pb)
    if (!is.null(m)) {
      x <- suppressMessages(read_marketdata(m))
      if (is.null(x)) {
        row <- m$download_args
        msg <- paste(names(row), map(row, format), sep = " = ", collapse = ", ")
        cli::cli_alert_warning("Invalid file for args: {.val {msg}}")
      }
    }
    NULL
  })
  cli::cli_process_done(id = pb)
  cli::cli_alert_info("{length(ms)} files downloaded")
  invisible(NULL)
}
