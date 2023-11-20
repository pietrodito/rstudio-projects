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


echo "Setup will now exit"
exit