#' @export
init_log_format <- function(file = "logs/log.txt") {
  
  box::use( logger [...])
  
  log_layout (
    layout_glue_generator(
      paste(
        "{crayon::bold(colorize_by_log_level(level, levelr))}",
        "{grayscale_by_log_level(
           paste0('[',format(time, \"%m-%d %H:%M:%OS3\"), ']'), levelr)}",
        "{grayscale_by_log_level(paste0(pid, '/', fn), levelr)}",
        "{grayscale_by_log_level('|', levelr)}",
        "{grayscale_by_log_level(msg, levelr)}")
    )
  )
  
  log_appender(appender_console, index = 1)
  log_appender(appender_file("logs/log.txt"), index = 2)
  
  if(Sys.getenv("DEBUG") != "NO") {
    log_threshold(TRACE, index = 1)
    log_threshold(TRACE, index = 2)
  }
} 
