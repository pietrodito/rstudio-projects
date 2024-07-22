# Tabulatorr

  An [htmlwidget][1] to integrate JS [tabulator][2] to [R Shiny][3]. 
  
[1]: https://www.htmlwidgets.org/ 
[2]: https://www.tabulator.info/
[3]: https://www.rstudio.com/products/shiny/

_____

## Useful links

+ https://mastering-shiny.org/
+ https://book.javascript-for-r.com/ 
+ https://deanattali.com/blog/htmlwidgets-tips/


______

## TODO

-   Utiliser le cell context menu pour changer contenu, ou filter ligne !
-   Utilier le header menu pour supprimer/renommer colonne /!\ il faut envoyer un event vers R Shiny.


### LOW 
-   Modify `renderTabulator` to accept data directly: seems hard

-   There is a possible bug with module / nested module to test see <https://github.com/rstudio/DT/blob/main/R/shiny.R> `renderDataTable` function comments