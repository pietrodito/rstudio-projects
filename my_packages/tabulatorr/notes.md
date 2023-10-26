# Notes about tabulator package

-   tabulator aims to integrate `tabulator.js` as a shiny widget

## TODO

-   Utiliser le cell context menu pour changer contenu, ou filter ligne !
-   Utilier le header menu pour supprimer/renommer colonne /!\ il faut envoyer un event vers R Shiny.


### LOW 
-   Modify `renderTabulator` to accept data directly: seems hard

-   There is a possible bug with module / nested module to test see <https://github.com/rstudio/DT/blob/main/R/shiny.R> `renderDataTable` function comments
