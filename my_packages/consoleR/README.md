This package is a set of tools to use RStudio it prevents the IDE to restart each time you change active project.

## TODO
+ Put `.projects.rds` & `.sha1sum_footprints` in a same hidden dir

## Issues with rhino

+ Hard to set up with renv()
+ I've created a function `install_my_packages_inside_rhino`
  - TODO create a `create_rhino_app` that will use:
    - `rhino::init()` and then `install_my_packages_inside_rhino` 
    - `use_rhino_dockerfile`