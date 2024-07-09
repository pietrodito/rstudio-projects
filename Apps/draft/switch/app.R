# app.R
switchInput <- function(id, label, checked = TRUE) {
  
  input <- tags$input(
    id = id, 
    type = "checkbox", 
    class = "switchInput"
  )
  
  if(checked)
    input <- htmltools::tagAppendAttributes(input, checked = NA)
  
  form <- tagList(
    p(label),
    tags$label(
      class = "switch",
      input,
      tags$span(class = "slider")
    )
  )
  
  path <- normalizePath("./assets")
  
  deps <- htmltools::htmlDependency(
    name = "switchInput",
    version = "1.0.0",
    src = c(file = path),
    script = "binding.js",
    stylesheet = "styles.css"
  )
  
  htmltools::attachDependencies(form, deps)
}