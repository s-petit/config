#!/bin/bash
if [[ -z "$1" ]] ; then
    >&2 echo 'you have to specify a dump file as an argument for this script'
    exit 0
fi

if [[ -z "$2" ]] ; then
    >&2 echo 'you have to specify a db name to install as an argument for this script'
    exit 0
fi

dumpfile=$1;
dbname=$2;
dump_location=/home/spetit/Documents/dumps_prod;
extension="${dumpfile#*.}";
filename="${dumpfile%%.*}";

# download dump from repo
>&2 echo 'Downloading dump...'
scp developer@mirakl-dump.mirakl.net:$dumpfile $dump_location/$dumpfile;    
>&2 echo 'Download done.';
#unzip dump
bzip2 -d $dump_location/$dumpfile; 

#rename dump
mv $dump_location/$filename.sql $dump_location/$dbname.sql;

>&2 echo 'Installing dump...'

echo "-------------  CREATING AND IMPORT $dbname -------------";
psql -U postgres -c "DROP DATABASE IF EXISTS $dbname;"
psql -U postgres -c "CREATE DATABASE $dbname WITH OWNER = mirakl ENCODING 'UTF8';"

psql -U postgres -d $dbname -c 'CREATE EXTENSION hstore;'
psql -U postgres -d $dbname -c 'CREATE EXTENSION pg_trgm;'
psql -U postgres -d $dbname -c 'CREATE EXTENSION pgcrypto;'
psql -U postgres -d $dbname -c 'CREATE EXTENSION unaccent;'
psql -U postgres -d $dbname -c 'CREATE EXTENSION "uuid-ossp";'
psql -U mirakl $dbname < /home/spetit/Documents/dumps_prod/$dbname.sql
echo "------------- $dbname IMPORT DONE -------------";
>&2 echo 'Installing done.';
                                      
#remove dump
rm $dump_location/$dbname.sql;

