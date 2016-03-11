#!/bin/bash
if [[ -z "$1" ]] ; then
    echo 'you have to specify the version you want to keep for this merge (usually the N+1 SNAPSHOT)'
    exit 0
fi

ruby /home/spetit/scripts/fix_maven_conflicts.rb -v $1
find . -name "*.xml.conflicts" -type f -delete

