tableDesignerServer <- function(id,
                                table_name,
                                nature,
                                finess = reactive(NULL)) {
  
  stopifnot(is.reactive(table_name))
  stopifnot(is.reactive(nature))
  stopifnot(is.reactive(nature))
  
  moduleServer(id, function(input, output, session) {
    
    load_ovalide_tables(nature)
    
    named_finess <- reactive({read_named_finess(nature())})
    
    ## Needed to read formatting before computing table
    ## You have to reset it each time table name changes
    poll_countdown <- zero_first_time_then_wait_ms(1000)
    
    table <- make_a_reactive_table(poll_countdown,
                                   nature,
                                   table_name)
    
    formatting <- make_a_reactive_formatting(poll_countdown,
                                             session,
                                             nature,
                                             table_name)
    
    state <- reactiveValues()
    update_state_from_formatting(state, formatting)
    
    dt_table <- reactive({ovalide::format_table(table(),
                                                input$finess,
                                                state)})
    
    ns <- session$ns

    render_table_name(table_name, state, formatting, output)
    render_finess_input(session, named_finess, finess)
    render_table(dt_table, output)
    render_description_output(session, state)
    render_rm_filter_list(output, input, state, ns)
    render_translation_inputs(output, state, ns)

    event_save(input, state, table_name, nature)
    
    event_translate(input, state)
    event_translate_1st_col_start(input, state)
    event_translate_1st_col_stop(input, state)
    event_translate_1st_col(input, state, table)
    
    event_rm_col(input, state)
    event_add_filter(input, state, dt_table)
    event_undo(input, state)
    
    event_log_current_state(input, state, table)
    event_undo_list(input, state)
    
    event_description_update(input, state)
    
    event_rm_filter(input, state)
  })
}

load_ovalide_tables <- function(nature) {
  observe({
    req(nature)
    ovalide::load_ovalide_tables(nature())
  })
}
    
zero_first_time_then_wait_ms <- function(wait_ms) {
  local({
    first_time = TRUE;
    function(reset = FALSE) {
      if( first_time) {
        first_time <<- FALSE
        0
      } else {
      if (reset) first_time <<- TRUE
      wait_ms
      }
    }
  })
}


make_a_reactive_table <- function(poll_countdown,
                                  nature,
                                  table_name) {
  reactive({
    req(table_name())
    poll_countdown(reset = TRUE)
    ovalide::ovalide_table(nature(), table_name())
  })
}


make_a_reactive_formatting <- function(poll_countdown,
                                       session,
                                       nature,
                                       table_name) {
  reactivePoll(
    poll_countdown,
    session,
    checkFunc = function() {
      ovalide::table_format_last_changed(table_name(),
                                         nature())
    },
    valueFunc = function() {
      ovalide::read_table_format(table_name(),
                                 nature())
    }
  )
}

read_named_finess <- function(nature) {
  ovalide::load_score(nature)
  scores <- ovalide::score(nature)
  (named_finess <- scores$Finess)
  names(named_finess) <- scores$Libellé
  named_finess
}

update_state_from_formatting <- function(state, formatting) {
  observe({
    purrr::iwalk(formatting(), \(x, idx) state[[idx]] <- x)
  })
}

render_description_output <- function(session, state) {
  observe({
    shiny::updateTextAreaInput(session, "description",
                               value = state$description)
  })
}

render_table_name <- function(table_name,
                              state, 
                              formatting,
                              output) {
  output$table_name <- shiny::renderUI({
    
     changes_not_saved <- NULL
     
     if ( ! identical(reactiveValuesToList(state), formatting())) {
       changes_not_saved <-
         shiny::h5("modifications non sauvegardées",
                   style = "color:red")
     }
     
      list(shiny::h3(table_name()),
           changes_not_saved)
  })
}

render_finess_input <- function(session,
                                named_finess,
                                finess) {
  
    
  observe({
    req(named_finess)

    shiny::updateSelectInput(session, "finess",
                             choices = named_finess(),
                             selected = isolate(finess()))
  })
}

render_table <- function(dt_table, output) {
  output$table <- DT::renderDT(
    dt_table(),
    rownames = FALSE,
    selection = list(mode = "single", target = "cell"),
    options   = list(dom  = "t"     , pageLength = -1))
}

render_translation_inputs <- function(output, state, ns) {
  observe({
    text_input_list_from <- function(original, translated, ns) {
      purrr::map2(original, translated,
                  ~ shiny::textInput(ns(.x), .x, .y))
    }
    output$translation_columns <- shiny::renderUI({
      text_input_list_from(state$selected_columns,
                           state$translated_columns, ns)})
    output$translation_rows <- shiny::renderUI({
      req(state$proper_left_col)
      req(state$row_names)
      text_input_list_from(state$row_names,
                           state$rows_translated, ns)})
  })
}

render_rm_filter_list <- function(output, input, state, ns) {
  observe({
    output$rm_filter_button_list <- shiny::renderUI({
      req(state)
      choices <- purrr::map(state$filters, ~ .x$select_choice)
      names(choices) <- purrr::map_chr(state$filters, ~ .x$select_name)
      list(
        shiny::selectInput(ns("rm_filter_choice"), "Filtres", choices),
        shiny::actionButton(ns("rm_filter"), "Supprimer filtre")
      )
    })
  })
}

current_state_to_parameter_list <- function(state) {
  current_state <- reactiveValuesToList(state)
  current_state$undo_list <- NULL
  current_state
}

create_state <- current_state_to_parameter_list

save_state_to_undo_list <- function(state) {
  last_undo <- NULL
  this_undo <- create_state(state)
  l <- length(state$undo_list)
  if (l > 0) {
    last_undo <- state$undo_list[[l]]
  }
  if( ! identical(last_undo, this_undo)) {
    state$undo_list <- c(state$undo_list, list(this_undo))
  }
}

load_state_from <- function(undo, state) {
  purrr::imap(undo, \(x, idx) state[[idx]] <- x)
}

a_cell_is_selected <- function(input) {
  ncol(input$table_cells_selected) > 0
}

event_save <- function(input, state, table_name, nature) {
  observeEvent(input$save, {
    
    save_state <- reactiveValuesToList(state)
    
    ovalide::write_table_format(table_name(), nature(), save_state)
  })
}

event_translate_1st_col_start <- function(input, state) {
  observeEvent(input$translate_first_col_start, {
    if( ! state$proper_left_col) {
      save_state_to_undo_list(state)
      state$proper_left_col <- TRUE
    }
  })
}

event_translate_1st_col_stop <- function(input, state) {
  observeEvent(input$translate_first_col_stop, {
    if(state$proper_left_col) {
      save_state_to_undo_list(state)
      state$proper_left_col <- FALSE
    }
  })
}

event_undo <- function(input, state) {
  observeEvent(input$undo, {
    suppress_last_element <- function(l) l[-length(l)]
    l <- length(state$undo_list)
    if (l > 0) {
      undo <- state$undo_list[[l]]
      load_state_from(undo, state)
      state$undo_list <- suppress_last_element(state$undo_list)
    }
  })
}

event_translate_1st_col <- function(input, state, table) {
  observeEvent(state$proper_left_col, {
    if ( ! is.null(state$selected_columns)) {
      (
        table()
        |> dplyr::pull(state$selected_columns[1])
        |> unique()
      ) -> x
      state$row_names <- x
      if (length(state$rows_translated) == 0) {
        state$rows_translated <- x
      }
    }
  })
}

event_translate <- function(input, state) {
  observeEvent(input$translate, {
    save_state_to_undo_list(state)

    state$translated_columns <-
      purrr::map_chr(state$selected_columns,
                     ~ input[[as.character(.x)]])

    if (state$proper_left_col) {
      state$rows_translated <-
        purrr::map_chr(state$row_names,
                       ~ input[[as.character(.x)]])
    }
  })
}

event_add_filter <- function(input, state, dt_table) {
  observeEvent(input$add_filter, {
    if (a_cell_is_selected(input)) {
      save_state_to_undo_list(state)
      col_nb <- input$table_cells_selected[1, 2] + 1
      row_nb <- input$table_cells_selected[1, 1]
      pick_value_column <- state$translated_columns[col_nb]
      filter_column <- state$selected_columns[col_nb]
      value <- dt_table()[row_nb, pick_value_column] %>% dplyr::pull()
      state$filters <- c(state$filters, list(list(
        select_name = paste(filter_column, "≠", value),
        select_choice = paste0(filter_column, "_", value),
        column = filter_column,
        value = value
      )))
    }
  })
}

event_rm_col <- function(input, state) {
  observeEvent(input$rm_col, {
    if (a_cell_is_selected(input)) {
      save_state_to_undo_list(state)
      col_nb <- input$table_cells_selected[1, 2] + 1
      column <- state$selected_columns[col_nb]
      state$selected_columns <- state$selected_columns[-col_nb]
      state$translated_columns <-
        state$translated_columns[-col_nb]
    }
  })
}

event_log_current_state <- function(input, state, table) {
  observeEvent(input$log_current_state, {
    
    line <- function() cat(paste0(rep("-", 80), collapse = ""), "\n")
    line()
    cat(" --- LOG has been pressed ---\n")
    cat("\n")
    print(Sys.time())
    cat("\n")
    cat(" --- LOG has been pressed ---\n")
    line()
    print(table()
          %>% dplyr::filter(finess_comp == input$finess)
          %>% dplyr::select(- finess_comp))
    line()
    print(current_state_to_parameter_list(state))
    line()
  })
}

event_undo_list <- function(input, state) {

  observeEvent(input$undo_list, {
    line <- function() cat(paste0(rep("-", 80), collapse = ""), "\n")
    line()
    print(Sys.time())
    line()
    print(state$undo_list)
  })
}

event_rm_filter <- function(input, state) {
  observeEvent(input$rm_filter, {
    req(state$filters)
    save_state_to_undo_list(state)
    state$filters <-
      purrr::discard(state$filters,
                     \(f) f$select_choice == input$rm_filter_choice)
  })
}

event_description_update <- function(input, state) {
  observeEvent(input$description, {
      state$description <- input$description
  })
}
