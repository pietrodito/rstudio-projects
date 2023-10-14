# DIVALO
The purpose of this application is to exploit the french [OVALIDE][1] data.

It contains:
  - a shiny app built with the [Rhino][2] framework
  - a [PostgreSQL][3] database
  - and the [pgAdmin][4] tool.

It also uses parallel processes scanning for OVALIDE files to update the database. More details [below](#update-database-with-ovalide-files)

See also the [compose.yml][5] file.


## ISSUES

- Doing ovalide_utils ovalide: raw -> db for key/values 
- CANNOT use rhino::pkg_install without reinstalling rstudio!!!

## TODO

- db_updater: le dispatcher 

- Gérer les cas où des colonnes apparaissent ou disparaissent
- Si colonne en moins `dbAppendTable` gère completement
- Si colonne en plus il faut ALTER TABLE

- Régler les pbs de dépendances dans db_updater

- Use the db_updater PoC to fill database with data
  - PoC added to app
  - Now I have to deal with real files
  - Two major cases 1) scores 2) ovalide .csv
  - Add everything to database in raw format


## Focus on important design decisions

### Deploy Rhino app in container

See [Dockerfile](./Dockerfile):
+ install R package `renv`
+ copy `renv.lock` to container
+ call `renv::restore()`

### Update database with ovalide files

PoC can be found in this [project][6].

- The db_updater got one script `probe_dir.R`
- The script accepts one arg eg. `mco_oqn`
- The `entrypoint.sh` launches 8 script in background
  - [mco, had, smr, psy]  x  [dgf, oqn]

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
