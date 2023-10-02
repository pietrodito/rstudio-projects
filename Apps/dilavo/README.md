## TODO 

+ For each rhino app add a way to test modules interactively
  - use shiny.router 
  
+ In consoleR add use_interactive_test_in_rhino
  - This function will scan for directory ./tests/interactive
  - each .R file in this dir will create a new page
  - the main.R will create two pages:
    - root: /       the app
    - dev:  /dev    a list of links with all pages
=> design seems to imply a nested router