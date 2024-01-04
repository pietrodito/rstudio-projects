#!/usr/bin/env bash 
#

echo "DB is setting up..."

DB_READY=1

while [ "$DB_READY" != 0 ]
do
  pg_isready -h db
  DB_READY=$?
  sleep 1
done

declare -a natures=(
  "MCO_DGF" "MCO_OQN" "HAD_DGF" "HAD_OQN"
  "SMR_DGF" "SMR_OQN" "PSY_DGF" "PSY_OQN"
 )

 PGPASSWORD=postgres

if [ "$( psql -h db -XtAc \
     "SELECT 1 FROM pg_database WHERE datname='PSY_OQN'" )" = '1' ]
then
    echo "Databases already exist"
else
    echo "Creating dbs... "
    for i in "${natures[@]}"
    do
      createdb -h db "$i"
      psql -h db -d "$i" -c \
      'CREATE TABLE IF NOT EXISTS build_tables (
         name TEXT UNIQUE NOT NULL, 
         details TEXT NOT NULL ) '
    done
    echo "8 dbs created!"
fi

if [ "$( psql -h db -XtAc \
     "SELECT 1 FROM pg_database WHERE datname='UPD_LOG'" )" = '1' ]
then
    echo "Database UPD_LOG already exist"
else
    echo "Creating UPD_LOG db... "
      createdb -h db UPD_LOG 
      psql -h db -d UPD_LOG -c \
      'CREATE TABLE IF NOT EXISTS logs (
         champ TEXT NOT NULL, 
         statut TEXT NOT NULL,
         MAJ_csv TIMESTAMP,
         MAJ_tdb TIMESTAMP,
         MAJ_cle_val TIMESTAMP
         ) '
fi


echo "Setup will now exit"
exit