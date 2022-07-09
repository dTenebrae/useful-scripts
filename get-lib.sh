#!/bin/bash
# simple script to get all libs included in c header files in directory and subdir and pipe it to dnf provide command

# create an array
declare -a lib_arr=()

# find all files in all subdirectories with .h extension
# and put it into list

printf "Searching header files in directory/subdirectories... \n"
file_list=$(fd --extension h)
printf "Files found: $(echo "$file_list" | wc -l)\n"

for file in $file_list ; do

    # parse included modules to search with dnf
    LIB_LIST=$(cat $file | grep "#include" | awk -F ' ' '{print $2}' | sed 's:^.\(.*\).$:\1:')

    # iterate over list of lists and put it to dnf provide
    for lib in $LIB_LIST ; do
        if [[ $lib != std* ]]
        then
            printf "$lib ... "
            # getting only last paragraph of dnf provides output (ignoring error message, if not found)
            # TODO more smart way to find a lib, last one not always the best one
            # first string of it, and package name that matches regex
            # pretty hacky tho
            result=( $(dnf provides '*'$lib 2> /dev/null | tail -n 5 | head -n 1 | grep -Po '^.+?(?=-\d)') )
            # if nothing found (result is empty)
            if [[ -z "$result" ]]
            then
                printf "not found\n"
            else
                printf "$result\n"
                lib_arr+=$result
            fi
        fi
    done
done

printf "\n"
printf "=========== related packages found =============\n\n"
# print unique values
printf "%s\n" "${lib_arr[@]}" | sort -u
