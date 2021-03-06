
display_template_Addin <- function() {

  classes_ <- MarketData$show_templates()[['Class Name']]
  ui <- miniUI::miniPage(
    miniUI::miniTitleBar("rb3 View Template"),
    miniUI::miniContentPanel(
      shiny::selectInput("templateClass", label = shiny::h3("Template Classes"),
                  choices = classes_,
                  selected = 1),
      shiny::hr(),
      shiny::uiOutput('templateOutput')
    )
  )


  server <- function(input, output, session) {

    output$templateOutput <- shiny::renderUI({
      tpl_ <- MarketData$retrieve_template(input$templateClass)

      elm <- list(
        shiny::tags$p('Template ID: ', tpl_$id),
        shiny::tags$p('Filename: ', tpl_$filename),
        shiny::tags$p('File type: ', tpl_$file_type)
      )

      if (is(tpl_$fields, 'fields')) {
        elm[[ length(elm) + 1 ]] <- shiny::HTML(
          print(xtable::xtable(as.data.frame(tpl_$fields)),
                type = 'html', print.results = FALSE,
                html.table.attributes='class="data table table-bordered table-condensed"')
        )
      } else {
        parts_names <- names(tpl_$parts)
        ix <- 0
        for (nx in parts_names) {
          ix <- ix + 1
          elm[[ length(elm) + 1 ]] <- shiny::tags$p(sprintf('Part %d: %s\n', ix, nx))
          # if (! is.null(.$parts[[nx]]$lines))
          #   cat('Lines:', .$parts[[nx]]$lines, '\n')
          # else
          #   cat('Pattern:', .$parts[[nx]]$pattern, '\n')
          elm[[ length(elm) + 1 ]] <- shiny::HTML(
            print(xtable::xtable(as.data.frame(tpl_$parts[[nx]]$fields)),
                  type = 'html', print.results = FALSE,
                  html.table.attributes='class="data table table-bordered table-condensed"')
          )
        }
      }
      do.call(shiny::tags$div, elm)
    })

  }

  app <- shiny::shinyApp(ui = ui, server = server)
  viewer <- shiny::dialogViewer("rb3 Show Templates", width = 1200, height = 900)
  shiny::runGadget(app, viewer = viewer, stopOnCancel = TRUE)

}
