$(document).on("keypress", function (e) {
    Shiny.onInputChange("mydata", e.which);
});