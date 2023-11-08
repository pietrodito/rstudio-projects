ovalideTableSelectorUI <- function(id) {
  ns <- NS(id)
  
  shiny::uiOutput(ns("selector"))
}

ovalideTableSelectorServer <- function(id,
                                       finess,
                                       etablissement,
                                       nature,
                                       column_name,
                                       cell_value) {
  
  
  stopifnot(is.reactive(finess))
  stopifnot(is.reactive(nature))
  stopifnot(is.reactive(column_name))
  stopifnot(is.reactive(cell_value))
  
  selection <-  reactiveVal(list())
  
  result <- reactiveVal(NULL)
  
  moduleServer(
    id,
    function(input, output, session) {
      
      ns <- session$ns
      
      selection_update(nature, column_name, selection)
      
      render_tables(ns, input, output, finess, etablissement, nature,
                    column_name, cell_value, selection, result)
      
      observeEvent(input$table_choosen, {
        selection(ovalide::add_table(selection(), input$table_select))
        ovalide::write_selection(selection(), nature(), column_name())
        shiny::removeModal()
      })
      
      event_add_table(ns, input, nature)
      
      reactive(result())
    })
}   


selection_update <- function(nature, column_name, selection) {
  observe({
    
      
    req(nature())
    req(column_name())
    
    selection(ovalide::read_selection(nature(), column_name()))
  })
}

render_tables <- function(ns, input, output, finess, etablissement, nature,
                          column_name, cell_value, selection, result) {
  observe({
    output$selector <- shiny::renderUI({
      
      contactSelectorServer("contact", nature, finess)
      
      
      list(
        shiny::wellPanel(
          shiny::h1(id = ns("etab_label")  , etablissement()),
          shiny::h2(id = ns("finess_label"), finess()       ),
          shiny::h3(id = ns("column_label"), column_name()  ),
          shiny::h3(id = ns("value_label") , cell_value()   ),
          contactSelectorUI(ns("contact"))
        ),
        
        shiny::wellPanel(
          shiny::textOutput(ns("table_list_text")),
          (
            selection()
            |> purrr::map(\(x) ovalide::present_table(x, nature(), finess()))
            |> purrr::map(\(t)
                          DT::renderDT(t,
                                       rownames = FALSE,
                                       extensions = c("Buttons"#, "Select"
                                                      ),
                                       options  = list(dom  = "Bt",
                                                       pageLength = -1,
                                                       buttons = list(
                                                         list(
                                                           extend = "copy",
                                                           title = NULL,
                                                           text = 'Copier')))))
            |> purrr::map2(selection(), \(dt, tab_name)
                           shiny::wellPanel(
                             shiny::h3(ovalide::get_description(
                               tab_name,
                               nature()
                             )),
                             dt,
                             shiny::actionButton(ns(paste0("conf_", tab_name)),
                                                 "Config"),
                             shiny::actionButton(ns(paste0("rm_", tab_name)),
                                                 "Supprime table")))
          ),
          
          shiny::actionButton(ns("add_table"), "Ajouter une table")
        )
      )
    })
  })
  
  add_config_event <- function(associated_table) {
    to_eval <- glue::glue('
        if (is.null(input$rm_<<associated_table>>)) {
          observeEvent(input$conf_<<associated_table>>, {
            result("<<associated_table>>")
          })
        }', .open = "<<", .close = ">>")
    
    eval(parse(text = to_eval))
  }
  
  add_rm_event <- function(associated_table) {
    to_eval <- glue::glue('
        if (is.null(input$rm_<<associated_table>>)) {
          observeEvent(input$rm_<<associated_table>>, {
            selection(ovalide::rm_table(selection(), "<<associated_table>>"))
            ovalide::write_selection(selection(), nature(), column_name())
          })
        }
        ', .open = "<<", .close = ">>")
    
    eval(parse(text = to_eval))
  }
  
  observe({
    purrr::walk(selection(), add_config_event)
    purrr::walk(selection(), add_rm_event)
  })
}

event_add_table <- function(ns, input, nature) {
  
  observeEvent(input$add_table, {
    
    ovalide::load_ovalide_tables(nature())
    shiny::showModal(shiny::modalDialog(
      shiny::selectInput(
        ns("table_select"),
        "Choisissez une table...",
        choices = names(ovalide::ovalide_tables(nature()))),
      footer = tagList(
        shiny::modalButton("Annuler"),
        shiny::actionButton(ns("table_choosen"), "OK")
      )
    ))
  })
}
