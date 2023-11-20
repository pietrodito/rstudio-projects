# app/view/table_builder

box::use(
  builder_details/description
)

ui <- function(id) {
  
  box::use(
    
    ../logic/nature_utils
    [ all_fields, all_status, nature, ],
    
    shiny
    [ actionButton, column, fluidPage, fluidRow, NS,
      selectInput, tagList, textInput, textOutput,
      uiOutput, wellPanel, ],
    
    shinyjs
    [ useShinyjs, ],
    
    tabulatorr
    [ tabulatorOutput, ],
  )
  
  ns <- NS(id)
  fluidPage(
    useShinyjs(),
    fluidRow(
      textOutput(ns("debug")),
      column(4, 
             wellPanel(
               fluidRow(
                 column(3, 
                        selectInput(ns("field"), "Champ", all_fields, "mco"),
                 ),
                 column(3, 
                        selectInput(ns("status"), "Statut", all_status, "dgf"),
                 ),
                 column(6, 
                        wellPanel(
                          fluidRow(
                            column(6, 
                                   actionButton(ns("new_cancel"),
                                                "Nouvelle table",
                                                width = "100%"),
                            ),
                            column(6, 
                                   actionButton(ns("edit"), "Éditer",
                                                width = "100%"),
                            ),
                          )
                        ),
                 ),
               ),
               uiOutput(ns("table_name")),
               selectInput(ns("hospital"), "Établissement", NULL),
             )),
      column(4, 
             wellPanel(
               
               fluidRow(
                 column(3, actionButton(ns("undo"), "⟲ Undo", width = "100%")), 
                 column(3, actionButton(ns("redo"), "⟳ Redo", width = "100%")), 
                 column(6, actionButton(ns("save"),
                                        "💾 Sauvegarder", width = "100%") ), 
               ),
             )),
      column(4, 
             wellPanel(
               actionButton(ns("create_col"), "Ajouter des colonnes"),
             )),
    ),
      fluidRow(
        column(4, 
               wellPanel(
                 actionButton(ns("new_one"), "new one"),
               )
        ),
        column(4, 
               wellPanel(
                 actionButton(ns("new_two"), "new two"),
               )
        )),
    fluidRow(
      wellPanel(description$ui(ns("description")))
    ),
      fluidRow(
        wellPanel(
          tabulatorOutput(ns("table"))
        )
      )
  )
}

server <- function(id) {
  
  box::use(
    
    app/logic/db_utils
    [ build_tables, hospitals, load_build_table_details, ],
    
    app/logic/nature_utils
    [ nature, ],
    
    app/logic/table_builder_utils
    [ build_details, ],
    
    purrr
    [ walk, ],
    
    shiny
    [ actionButton,  modalButton, modalDialog, moduleServer, observe,
      observeEvent, reactive, reactiveVal, reactiveValues, renderText, renderUI,
      removeModal, req, selectInput, showModal, tagList, textInput,
      updateActionButton, updateSelectInput, updateTextInput, ],
    
    shinyjs
    [ disable, enable, hide, show, ],
    
    tabulatorr
    [ renderTabulator, tabulator, ],
  )
  
  moduleServer(
    id,
    function(input, output, session) {
      
      ns <- session$ns
      
      r <- reactiveValues()
      r$edit_mode <- FALSE
      
      details <- reactiveValues()
      
      update_details_description(details, r)
      
      update_ui_according_to_edit_mode(r, session, input, output)
      
      output$debug <- renderText({details$description})
      
      observe({
        r$table_name <- input$selected_name
        req(r$nature, r$table_name)
        
        ## TODO
        ## Wrong pattern
        ## I have to update each field of details
        ## see how I did it in old DILAVO
        ## I used reactivePoll
        details_non_reactive <- load_build_table_details(r$nature, r$table_name)
        details <- reactive(details_non_reactive)
        ## Wrong pattern
        
      })
      
      observe({
        r$nature <- nature(input$field, input$status)
        r$build_tables <- build_tables(r$nature)
      })
      
      observe({
        r$invaildate_table_name_selectInput
        r$build_tables <- build_tables(r$nature)
      })
      
      observe({
        req(r$nature)
        updateSelectInput(session, "hospital",
                          choices = hospitals(r$nature))
      })
      
      observeEvent(input$save, {
        box::use(
          ../logic/db_utils
          [ save_build_table_details, ], 
          
          shiny
          [ isolate, reactiveValuesToList, ],
        )
          
        if(r$edit_mode) {
          save_build_table_details(
            isolate(r$nature),
            isolate(input$edit_name),
            isolate(reactiveValuesToList(details))
          )
        }
        r$invaildate_table_name_selectInput <- stats::runif(1)
      })
      
      observeEvent(input$new_cancel, {
        ## TODO clear all details
        r$edit_mode <- ! r$edit_mode
      })
      

      observeEvent(input$undo, {
        if(r$edit_mode) {
          output$debug <- renderText({"UNDO"})
        }
      })
      
      output$table <- renderTabulator(
        tabulator(
          data.frame(x = letters),
          autoColumns = TRUE,
          layout = "fitColumns"
        )
      )
    }
  )
}

update_details_description <- function(details, r) {
  box::use( shiny[ reactive, ],)
  
  details <- description$server("description",
                                details,
                                reactive(r$edit_mode))
}
      
update_ui_according_to_edit_mode <- function(r, session, input, output) {
  
  box::use(
    purrr
    [ walk, ],
    
    shiny
    [ observe, renderUI, selectInput, textInput, updateActionButton, ],
    
    shinyjs
    [ disable, enable, hide, show, ],
  )
  
  observe({
    edit_ids <- c("create_col",
                  "undo",
                  "redo",
                  "save")
    non_edit_ids <- c("field",
                      "status")
    if(r$edit_mode) {
      updateActionButton(session, "new_cancel", "Annuler éditon")
      hide("edit", anim = TRUE, animType = "fade")
      walk(edit_ids    , enable )
      walk(non_edit_ids, disable)
      output$table_name <- renderUI({
        textInput(session$ns("edit_name"), label = "Nom de table",
                  value = input$selected_name,
                  placeholder = "Choissisez un nom pour la table")
      })
    } else {
      updateActionButton(session, "new_cancel", "Nouvelle table")
      show("edit", anim = TRUE, animType = "fade")
      walk(edit_ids    , disable)
      walk(non_edit_ids, enable )
      output$table_name <- renderUI({
        selectInput(
          session$ns("selected_name"),
          label = "Liste des tables",
          choices = r$build_tables
        )
      })
    }
  })
}