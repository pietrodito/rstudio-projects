ovalideScoreUI <- function(id) {
  ns <- NS(id)
    DT::DTOutput(ns("score_table"))
}

ovalideScoreServer <- function(id, nature) {
  
  stopifnot(shiny::is.reactive(nature))
  
  moduleServer(
    id,
    function(input, output, session) {
      
      column_nb     <- reactiveVal(NULL)
      column_name   <- reactiveVal(NULL)
      cell_value    <- reactiveVal(NULL)
      etablissement <- reactiveVal(NULL)
      finess        <- reactiveVal(NULL)
      
      observe({
        if( ! is.null(nature())) {
          ovalide::load_score(nature())
        }
      })
      
      output$score_table <-
        DT::renderDT(ovalide::score(nature()),
                     rownames = FALSE,
                     extensions = c('FixedColumns',"FixedHeader"),
                     selection = list(mode = "single", target = "cell"),
                     options   = list(dom  = "t"     ,
                                      autoWidth = TRUE,
                                      # pageLength = -1,
                                      scrollX = TRUE, 
                                      paging=FALSE,
                                      fixedHeader=TRUE,
                                      fixedColumns = list(leftColumns = 1,
                                                          rightColumns = 0)
                                      ))
      
      observe({
        req(input$score_table_cells_selected)
        row <- input$score_table_cells_selected[1]
        etablissement(ovalide::score(nature())[row, 1])
        finess(ovalide::score(nature())[row, 2] |> dplyr::pull(Finess))
        column_nb(input$score_table_cells_selected[2]
                                            + 1) #JS indexing 0, ...
        column_name(names(ovalide::score(nature()))[column_nb()])
        cell_value(ovalide::score(nature())[row, column_nb()] |> unlist())
      })
      
        list(
          column_nb     = column_nb    ,
          column_name   = column_name  ,
          cell_value    = cell_value   , 
          etablissement = etablissement, 
          finess        = finess       
          
        )
    })
}