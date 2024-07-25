export function enterKeyReleased(shiny_namespace) {
    $(document).on("keyup", function (e) {
        let ENTER_KEY_CODE = 13;
        if (e.keyCode == ENTER_KEY_CODE) {
            // Use random to trigger reactive
            console.log(shiny_namespace + "enterKeyReleased");
            Shiny.onInputChange(shiny_namespace + "enterKeyReleased",
                Math.random());
        }
    });
} 