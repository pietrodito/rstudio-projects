if (interactive()) {
  options(consoleR_server_name = "ITAK")
  packages_at_startup <- c("usethis",
                           "devtools",
                           "consoleR",
                           "fs")

  options(defaultPackages = c(getOption("defaultPackages"),
                              packages_at_startup))

  rm(packages_at_startup)
}
