#!/bin/bash
# simple script to get all libs included in c header file and pipe it to dnf provide command

# get path from script argument
CAT_PATH=$1

# parse included modules to search with dnf
LIB_LIST=$(cat $CAT_PATH | grep "#include" | awk -F ' ' '{print $2}' | sed 's:^.\(.*\).$:\1:')

# iterate over list of lists and put it to dnf provide
for lib in $LIB_LIST ; do
    if [[ $lib != std* ]] ; then
        printf $lib\\n
    fi
done
