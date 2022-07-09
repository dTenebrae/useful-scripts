#!/bin/bash
# simple script to get all libs included in c header files in directory and subdir and pipe it to dnf provide command

# declaration part
declare -a lib_arr=()
RED='\033[0;31m'
NC='\033[0m'
PS3='Please enter your choice: '
COUNTER=1

# find all files in all subdirectories with .h extension
# and put it into list

printf "Searching header files in directory/subdirectories... \n"

file_list=$(find . -type f -name "*.h")
n_files=$(echo "$file_list" | wc -l)
# printf "Files found: $(echo "$file_list" | wc -l)\n"
printf "Files found: $n_files\n"
read -n 1 -s -r -p "Press any key to continue"

for file in $file_list ; do

    # parse included modules to search with dnf
    LIB_LIST=$(cat $file | grep "#include" | awk -F ' ' '{print $2}' | sed 's:^.\(.*\).$:\1:')

    # iterate over list of lists and put it to dnf provide
    for lib in $LIB_LIST ; do
        if [[ $lib != std* ]]
        then
            # clear screen
            printf "\033c"
            printf "Files processed: $COUNTER of $n_files\n"
            printf "$lib ... "
            # getting only last paragraph of dnf provides output (ignoring error message, if not found)
            result=( $(dnf provides '*'$lib 2> /dev/null | grep -Po '^.+?(?=-\d)') )
            # if nothing found (result is empty)
            if [[ -z "$result" ]]
            then
                printf "${RED}not found${NC}\n"
            else
                printf "\n"
                # select from generated options
                select opt in "${result[@]}"
                do
                    printf "$opt\n"
                    lib_arr+=($opt)
                    break
                done
            fi
        fi
        COUNTER=$[$COUNTER+1]
    done
done

printf "\n"
printf "=========== related packages found =============\n\n"

#declare -p lib_arr

# print unique values
printf "%s\n" "${lib_arr[@]}" | sort -u
