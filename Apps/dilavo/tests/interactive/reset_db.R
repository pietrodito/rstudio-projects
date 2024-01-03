#' @export
ui <- function(id) {
  
  box::use(
    
    app/logic/nature_utils
    [ all_fields, all_status, nature, suffixe, ],
    
    purrr
    [ map, ],
    
    shiny
    [ actionButton, bootstrapPage, NS ],
  )
  
  ns <- NS(id)
  bootstrapPage(
    list(
      actionButton(ns("reset_all"), " !! Reset all !!")
      ,
    map(all_fields, 
        function(field) {
          map(all_status, function(status) {
            nature <- nature(field, status)
            actionButton(ns(paste0("click_", suffixe(nature))),
                         paste0(" RESET ", field,  " ", status, " "))
                         })
            })
  )
    )
}

#' @export
server <- function(id) {
  
  box::use(
    app/logic/nature_utils 
    [ all_natures, nature, suffixe, ],
    
    app/logic/db_utils 
    [ db_reset, db_reset_all, ],
    
    purrr
    [ walk, ],
    
    shiny
    [ moduleServer, observeEvent, ],
  )
  
  moduleServer(id, function(input, output, session) {
    
    observeEvent(input$reset_all, db_reset_all())
    
    # TODO generate observe event for each button
    
    walk(all_natures, function(nature) {
      observeEvent(input[[paste0("click_", suffixe(nature))]], {
        db_reset(nature)
      })
    })
  })
}