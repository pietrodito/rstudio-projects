export function js_helpers() {
    enterKeyReleased();
}

function enterKeyReleased() {
    $(document).on("keyup", function (e) {
        let ENTER_KEY_CODE = 13;
        if (e.keyCode == ENTER_KEY_CODE) {
            // Use random to trigger reactive
            Shiny.onInputChange("enterKeyReleased", Math.random());
            console.log("Enter key released!")
        }
    });
} 