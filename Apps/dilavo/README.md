# DIVALO
The purpose of this application is to exploit the french [OVALIDE][1] data.

It contains:
  - a shiny app built with the [Rhino][2] framework
  - a [PostgreSQL][3] database
  - and the [pgAdmin][4] tool.

It also uses parallel processes scanning for OVALIDE files to update the database. More details [below](#update-database-with-ovalide-files)

See also the [compose.yml][5] file.


## ISSUES

- CANNOT use rhino::pkg_install without reinstalling rstudio!!!

## TODO

### table_builder

#### Create a new line in build_tables when saving
+ Use `dbplyr::copy_inline()`
+ Use `dbplyr::rows_insert(in_place = TRUE)`

### db_updater

#### Updater must maintain a state file for each NATURE
=> Last time updated / should modify this file when sending update message


#### Refactor 
+ `dbplyr::sql_query_upsert()`
+ https://dbplyr.tidyverse.org/articles/backend-2.htmlupsert




## Focus on important design decisions

### Deploy Rhino app in container

See [Dockerfile](./Dockerfile):
+ install R package `renv`
+ copy `renv.lock` to container
+ call `renv::restore()`

### Update database with ovalide files

PoC can be found in this [project][6].

- The `entrypoint.sh` launches 1 script in background `dispatcher.R`
- Each time a file is added the dispatcher launches a new script:
   - `probe_dir.R` which accepts one arg eg. `mco_oqn`
   - This script takes care of the uploading

### pgAdmin with no password at all

+ See [Dockerfile](./pgadmin/Dockerfile).
+ Reference in this [SO answer][7]

### Interactive test design

At launch, the app will search if a shell  environment variable `RHINO_PROD` has been set to `true`.

If not, the directory `./tests/interactive` will be scanned for `.R` files. Each R file needs to contain a module.

Each module will create a test page, and a panel with links to each page will be added at the bottom of the app.

The structure of the [app/main.R][8] file documents this behavior.


[1]: https://appsilon.github.io/rhino/index.html
[2]: https://www.atih.sante.fr/ovalide-outil-de-validation-des-donnees-des-etablissements-de-sante
[3]: https://www.postgresql.org/
[4]: https://www.pgadmin.org/
[5]: ./compose.yml
[6]: ../draft/PoC_db_updater_with_one_R_process_by_nature
[7]: https://stackoverflow.com/a/77016748/6537892
[8]: app/main.R
