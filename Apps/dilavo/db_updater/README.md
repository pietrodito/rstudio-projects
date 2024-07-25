# How it works

`entrypoint.sh` launches `dispatcher.R` script

The dispatcher waits for some file to appear in `ovalide_data/upload/`.

+ If the file is csv, it packs it in a zip archive with appropriate name
+ If this is a zip file, it unzips it in the appropriate nature dir
+ Then it launches `probe_dir.R` script in the nature dir.

The probe script:
+ reads files in parallel and update database accordingly.
+ removes all files
+ writes message to `ovalide_data/messages/message.txt`

# File format specifics

## Three types of file

### zip file containing all csv files

+ required name format `field.status.year.period.*.zip`

### csv file 

+ required name formt `+.+.+.+.table_code.*.csv`
+ cols needed:  champ annee statut periode ipe

### dashboard file

+ required name format `field.status.year.period.TDB.zip`
+ cols needed: ipe

### key_value file

+ cols needed:  champ annee statut periode ipe
