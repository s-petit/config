#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo 'you have to specify a dump file as an argument for this script'
    exit 0
fi

dumpfile=$1;
scp developer@mirakl-dump.mirakl.net:$dumpfile /home/spetit/Documents/dumps_prod/$dumpfile;      
bzip2 -dk $dumpfile.bz2;                                       

