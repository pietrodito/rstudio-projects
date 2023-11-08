.onLoad <- function(libname, pkgname) {

  options(prompt = get_prompt())
  show_current_dir_in_prompt(T)
}
