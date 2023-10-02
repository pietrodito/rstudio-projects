if (interactive()) {
  
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
  
  Sys.setenv(R_CONTEXT="dev")
}
