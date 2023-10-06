# DIVALO
The purpose of this application is to exploit the french [OVALIDE][1] data.

It contains a shiny app build with the Rhino framework, a [PostgreSQL][2] database and the [pgAdmin][3] tool.

See the [compose.yml][4] file.

## TODO

Multi-user ? 
 + One container for each user ?
cd("./")


## Update database with ovalide files

PoC can be found in this [project][5].

- 

## pgAdmin with no password at all

Reference in this [SO answer][6]

## Interactive test design

At launch, the app will search if a shell  environment variable `RHINO_PROD` has been set to `true`.

If not, the directory `./tests/interactive` will be scanned for `.R` files. Each R file needs to contain a module.

Each module will create a test page, and a panel with links to each page will be added at the bottom of the app.

The structure of the [app/main.R][7] file documents this behavior.


[1]: https://www.atih.sante.fr/ovalide-outil-de-validation-des-donnees-des-etablissements-de-sante
[2]: https://www.postgresql.org/
[3]: https://www.pgadmin.org/
[4]: ./compose.yml
[5]: ../draft/PoC_db_updater_with_one_R_process_by_nature
[6]: https://stackoverflow.com/a/77016748/6537892
[7]: app/main.R
