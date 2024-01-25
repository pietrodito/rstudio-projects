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

### Add colors to tabulator



### table_builder

#### HOW TODO

##### Generalisation

One table build is made of details, we gonna save those details as a list.
Each detail is a also a list.

For each detail create a sub-module`
+ Create ui detailInput
+ Create server detailServer, the server takes a detail list at creation, and keeps returning the detail list at each update by the user.
=> read `https://mastering-shiny.org/scaling-modules.html#inputs-and-outputs`


##### Thinking generalisation of the tool

I will use:
+ time keys: annee / periode
+ stat unit keys: ipe

##### Two major types of data source

+ Wide table format : 1 line / hospital - period

|  period | ipe         | #RSA |  volume | n - 1 |
|---------|-------------|------|---------|-------|
| 3       | ch soissons | x    | y       | z     |
| 3       | ch lens     | a    | b       | c     |
| 3       | chu lille   | m    | n       | o     |

+ Long table format : 1 line / information

|  period | ipe         | key    |  value |
|---------|-------------|--------|--------|
| 3       | ch soissons | #RSA   | x      |
| 3       | ch soissons | volume | x      |
| 3       | ch soissons | n - 1  | z      |

##### Two major types of data view

###### Score type table (1 line / hospital | long format)

+ add column:

if ( source type == wide ) {
  details <- (source_table_name, column_name)
}
if ( source type == long ) {
  details <- (source_table_name, key_column_name, value_column_name)
  ## Treat the case where key_column_name is not unique
  ## Or allow multiple value_column_name
}

######  type table (1 line / hospital | long format)

+ add column:

if ( source type == long ) {
  details <- (source_table_name, list(column_name))
}
if ( source type == wide ) {
  details <- (source_table_name, key_column_name, ASK_USER_VALUE_COL_NAME)
}

#### Create a new line in build_tables when saving
+ Use `dbplyr::copy_inline()`
+ Use `dbplyr::rows_upsert(in_place = TRUE)`

#### Add columns
+ Select one or multiple columns from an existing table

#### Add rows
+ Select one column and one value

### db_updater

#### Updater must maintain a state file for each NATURE
=> Last time updated / should modify this file when sending update message


#### Refactor 
+ `dbplyr::rows_upsert()`
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
