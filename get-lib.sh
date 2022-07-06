#!/bin/bash
# simple script to get all libs included in c header file and pipe it to dnf provide command

# create an array
declare -a arr=()

# get path from script argument
CAT_PATH=$1

# parse included modules to search with dnf
LIB_LIST=$(cat $CAT_PATH | grep "#include" | awk -F ' ' '{print $2}' | sed 's:^.\(.*\).$:\1:')

printf "============= found in .h ================\n\n"

# iterate over list of lists and put it to dnf provide
for lib in $LIB_LIST ; do
    if [[ $lib != std* ]] ; then
        printf $lib\\n
        # getting only last paragraph of dnf provides output
        # first string of it, and package name that matches regex
        # pretty hacky tho
        arr+=( $(dnf provides '*'$lib | tail -n 5 | head -n 1 | grep -Po '^.+?(?=-\d)') )
    fi
done

printf "\n"
printf "=========== related packages =============\n\n"
# print unique values
printf "%s\n" "${arr[@]}" | sort -u
printf "\n"
