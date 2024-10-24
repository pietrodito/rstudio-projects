if (interactive()) {
  
  if(! "consoleR" %in% utils::installed.packages()) {
      cli::cli_alert_danger("Package consoleR not installed...")
      cli::cli_alert_info(
        "You have to run the code below and restart the session") 
      cli::cat_line("source('~/INSTALL_MY_PACKAGES.R')") 
    
  } else {

    options(consoleR_server_name = "ITAK")
    packages_at_startup <- c("usethis",
                             "devtools",
                             "consoleR",
                             "fs")

    options(defaultPackages =
              c(
                packages_at_startup,
                options("defaultPackages")[[1]]
              )
    )
    
    
    rm(packages_at_startup)
  }
  
}
