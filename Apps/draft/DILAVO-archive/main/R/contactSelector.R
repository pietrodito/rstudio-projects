contactSelectorUI <- function(id) {
  ns <- NS(id)
  shiny::wellPanel(
    shiny::h3("Contacts"),
    DT::DTOutput(ns("contact_table")),
    shiny::hr(),
    shiny::actionButton(ns("add_contact"), "Ajouter contact"),
    shiny::actionButton(ns("rm_contact"), "Supprimer contact")
  )
}


contactSelectorServer <- function(id, nature, finess) {
  moduleServer(
    id,
    function(input,  output, session) {
      
      ns <- session$ns
      
      contacts <- shiny::reactiveVal(NULL)
      
      observe({
        contacts <- contacts(ovalide::read_contact(nature(), finess()))
      })
      
      output$contact_table <- DT::renderDT({
        
        if (length(contacts()) == 0) {
          tibble::tibble(Attention = "Aucun contact associé")
        } else {
          tibble::tibble(Email = contacts())
        }},
        rownames = FALSE,
        extensions = c("Buttons"),
        
        options   = list(dom  = "Bt"     , pageLength = -1,
                         buttons = list(
                           list(
                             extend = "copy",
                             title = NULL,
                             header = FALSE,
                             text = 'Copier emails')
                         )
        )
      )
      
      observeEvent(
        input$add_contact, {
          shiny::showModal(
            shiny::modalDialog(
              shiny::selectInput(ns("email_to_add"),
                                 "Email",
                                 multiple = TRUE,
                                 selectize = TRUE,
                                 choices =
                                   ovalide::all_contacts( nature() )),
              shiny::actionButton(ns("confirm_add"), "Ajoute")
            )
          )
        }
      )
      
      observeEvent(
        input$rm_contact, {
          shiny::showModal(
            shiny::modalDialog(
              shiny::selectInput(ns("email_to_rm"),
                                 "Email",
                                 choices = contacts()),
              shiny::actionButton(ns("confirm_rm"), "Supprime")
            )
          )
        }
      )
      
      observeEvent(
        input$confirm_add, {
          contacts(ovalide::add_contact(contacts(), input$email_to_add))
          ovalide::write_contact(nature(), finess(), contacts())
          removeModal()
        }
      )
      
      observeEvent(
        input$confirm_rm, {
          contacts(ovalide::rm_contact(contacts(), input$email_to_rm))
          ovalide::write_contact(nature(), finess(), contacts())
          removeModal()
        }
      )
      
    }
  )
}