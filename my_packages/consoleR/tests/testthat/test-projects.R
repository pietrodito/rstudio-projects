library(consoleR)

if (interactive()) {

  cd("~/_own_packages/consoleR/")
  build_package()
  .rs.api.restartSession()

  proj_reset_list()
  proj_list()

  cd("~/_own_packages/consoleR/")
  proj_add()
  proj_list()

  cd("~/_own_packages/keyboardShortcutAddin/")
  proj_add()
  proj_list()
}
