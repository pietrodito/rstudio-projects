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

