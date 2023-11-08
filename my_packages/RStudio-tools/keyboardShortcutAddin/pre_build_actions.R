(function() {
  message("Copying rstudio kbd_shortcuts to project...")

  kbd_shortcut_dir <- "~/.config/rstudio/keybindings/"
  kbd_shorcut_filpath <-
    fs::dir_ls(
      kbd_shortcut_dir,
      regexp = "\\.json$")

  fs::dir_create("./kbd_shorcuts/")
  fs::file_copy(kbd_shorcut_filpath,
                "./kbd_shorcuts/",
                overwrite = TRUE)

})()


