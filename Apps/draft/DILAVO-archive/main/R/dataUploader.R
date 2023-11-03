dataUploaderUI <- function(id) {
  ns <- NS(id)
  tagList(
    shiny::h3("Téléversez le fichier..."),
    shiny::fileInput(ns("file"), "Parcourir..."),
    shiny::uiOutput(ns("what_file_champ")),
    shiny::uiOutput(ns("what_file_statut")),
    shiny::uiOutput(ns("what_file_data"))
  )
}


dataUploaderServer <- function(id,
                               champ,
                               statut,
                               data) {
  moduleServer(
    id,
    function(input, output, session) {
      output$what_file_champ  <- shiny::renderUI({
        shiny::h4(paste("Champ :"  , champ()))})
      output$what_file_statut <- shiny::renderUI({
        shiny::h4(paste("Statut :" , statut()))})
      output$what_file_data   <- shiny::renderUI({
        shiny::h4(paste("Données :", data()))})
      
      
      upload_details <- reactive({
        req(input$file)
        input$file
      })
      
      observeEvent(upload_details(), {
        datapath <- upload_details()$datapath
        if ( data() == "Scores" ) {
          ovalide::read_score_csv_file(datapath,
                                       ovalide::nature(champ(), statut()))
          ovalide::unload_ovalide_scores(nature(champ(), statut()))
        }
        if ( data() == "Tables" ) {
          progressr::withProgressShiny(
            message = "Lit les tables ovalide",
            detail = "Dézippe le fichier...",
            value = 0, {
              ovalide::read_zip_table_file(datapath,
                                           ovalide::nature(champ(),
                                                           statut()))
            })
          ovalide::unload_ovalide_tables(nature(champ(), statut()))
        }
        if ( data() == "Contacts" ) {
          ovalide::read_emails_from_raw_html_page(nature(), datapath)
        }
        session$reload()
      })
    })
}