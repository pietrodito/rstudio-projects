#' @export
contacts <- function(emails = character(0)) {
  
  ((
    emails
    |> unique()
    |> sort()
  ) -> emails)
  
  structure(
    emails,
    class = "contacts"
  )
}

contact_filepath <- function(nature, finess) {
  glue::glue("{data_save_dir(nature)}/{finess}.contacts.rds")
}

#' @export
write_contact <- function(nature, finess, contacts) {
  readr::write_rds(contacts, contact_filepath(nature, finess))
}

#' @export
read_contact <- function(nature, finess) {
  file <- contact_filepath(nature, finess)
  if (fs::file_exists(file)) {
    readr::read_rds(file)
  } else {
    contacts()
  }
}

#' @export
add_contact <- function(contacts, email) {
  contacts(c(contacts, email))
}

#' @export
rm_contact <- function(contacts, email) {
  contacts(setdiff(contacts, email))
}

sort_emails_by_domain_name <- function(emails) {
  (
    emails
    |> tibble::tibble()
    |> dplyr::mutate(domain = stringr::str_extract(emails, "@.*"))
    |> dplyr::mutate(domain = stringr::str_remove(domain, "@"))
    |> dplyr::arrange(domain, emails)
    |> dplyr::pull(emails)
  )
}


all_contacts_filepath <- function(nature) {
  glue::glue("{data_save_dir(nature)}/all.contacts.rds")
}

#' @export
read_emails_from_raw_html_page <- function(nature, filepath) {

  ## email pattern found @ https://emailregex.com/
  email_pattern <- "\"\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}\\b\""
  grep_cmd      <- paste("grep -E -o", email_pattern, filepath)
  
  write_emails <- function(emails) {
    readr::write_rds(emails, all_contacts_filepath(nature))}

  (
    system(grep_cmd, intern = TRUE)
    |> unique()
    |> sort_emails_by_domain_name()
    |> write_emails()
  )
}

#' @export
all_contacts <- function(nature) {
  file <- all_contacts_filepath(nature)
  if (fs::file_exists(file)) {
    readr::read_rds(file)
  } else {
    character(0)
  }
}