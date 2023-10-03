# DIVALO
The purpose of this application is to exploit the french [OVALIDE][1] data.

It contains a shiny app build with the Rhino framework, a [PostgreSQL][2] database and the [pgAdmin][3] tool.

See the [compose.yml][4] file.

## TODO

## Interactive test design

At launch, the app will search if a shell  environment variable `RHINO_PROD` has been set to `true`.

If not, the directory `./tests/interactive` will be scanned for `.R` files. Each R file needs to contain a module.

Each module will create a test page, and a panel with links to each page will be added at the bottom of the app.

The structure of the [app/main.R][5] file documents this behavior.


[1]: https://www.atih.sante.fr/ovalide-outil-de-validation-des-donnees-des-etablissements-de-sante
[2]: https://www.postgresql.org/
[3]: https://www.pgadmin.org/
[4]: ./compose.yml
[5]: app/main.R