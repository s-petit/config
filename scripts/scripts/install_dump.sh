#!/bin/bash
if [[ -z "$1" ]] ; then
    echo 'you have to specify a db name as an argument for this script'
    exit 0
fi

dbname=$1;

echo "-------------  CREATING AND IMPORT $dbname -------------";
psql -U postgres -c "DROP DATABASE IF EXISTS $dbname;"
psql -U postgres -c "CREATE DATABASE $dbname WITH OWNER = mirakl ENCODING 'UTF8';"

psql -U postgres -d $dbname -c 'CREATE EXTENSION hstore;'
psql -U postgres -d $dbname -c 'CREATE EXTENSION pg_trgm;'
psql -U mirakl $dbname < /home/spetit/Documents/dumps_prod/$dbname.sql
echo "------------- $dbname IMPORT DONE -------------";

