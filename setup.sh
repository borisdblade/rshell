#!/usr/bin/env bash

SP_LINE=""
PP_LINE=""

PEM_PATH=""
SOURCE_PATH=""

SCRIPT_PATH=""
SCRIPT_PATH_DEFAULT="/usr/local/bin/rsh"

# Local vars for setup only
PEM_ARRAY=()
CHOSEN_PEM_INDEX=0
CHOSEN_PEM=""
USER_PEM_PATH=""

# Copy main script file to executables folder (SCRIPT_PATH)
installScript()
{
    printf "Where do you want to install script:\n"
    printf "1) /usr/local/bin/rsh   # default\n"
    printf "2) Enter custom path\n"
    read SCRIPT_PATH_INDEX

    if [ $SCRIPT_PATH_INDEX -eq 1 ]
    then
        SCRIPT_PATH="$SCRIPT_PATH_DEFAULT"
    else
        printf "Enter script root path:\n"
        read SCRIPT_PATH
    fi

    sudo cp -f rsh.sh "$SCRIPT_PATH"
    sudo chmod +x "$SCRIPT_PATH"
}

addPemPath()
{
    # Try to locate pem file automatically
    locatePemFile

    if [ -z "$PEM_PATH" ]
    then
        printf "Enter your .pem file path: "
        read PEM_PATH
        PEM_PATH="PEM_PATH=$PEM_PATH"
    else
        PEM_PATH="PEM_PATH=$PEM_PATH"
    fi

    awk 'NR=='"$PP_LINE"'{$0="'"$PEM_PATH"'"}1' config/config.sh > config/config.tmp && mv config/config.tmp config/config.sh
    awk 'NR=='"$PP_LINE_ORG"'{$0="'"$PEM_PATH"'"}1' setup.sh > setup.tmp && mv setup.tmp setup.sh
}

addSourcePath()
{
    if [ -z "$SOURCE_PATH" ]
    then
        SOURCE_PATH=$(pwd)
        SOURCE_PATH="SOURCE_PATH=$SOURCE_PATH"
        awk 'NR=='"$SP_LINE"'{$0="'"$SOURCE_PATH"'"}1' rsh.sh > rsh.tmp && mv rsh.tmp rsh.sh
        awk 'NR=='"$SP_LINE_ORG"'{$0="'"$SOURCE_PATH"'"}1' setup.sh > setup.tmp && mv setup.tmp setup.sh
    fi
}

# Add paths of source and pem (SOURCE_PATH && PEM_PATH) to config file itself (config/config.sh)
addConfigLines()
{
    addPemPath
    addSourcePath
}

# Set path line numbers from config file
defineConfigLines()
{
    SP_LINE=$(awk '/SOURCE_PATH/{ print NR; exit }' ./rsh.sh)
    PP_LINE=$(awk '/PEM_PATH/{ print NR; exit }' ./config/config.sh)

    SP_LINE_ORG=$(awk '/SOURCE_PATH/{ print NR; exit }' ./setup.sh)
    PP_LINE_ORG=$(awk '/PEM_PATH/{ print NR; exit }' ./setup.sh)
}

# Setup steps
runSetup()
{
    printf "Setting up RSH script...\n"

    # Read config file, and find where important lines are
    defineConfigLines

    # Add these lines
    addConfigLines

    # Copy main script file to executables folder (SCRIPT_PATH)
    installScript

    # End
    printf "${GRN}Setup done!\n${NC}"
}

locatePemFile()
{
    printf "${GRN}Locating ${BS}.pem${BE} file...\n"

    for item in $(cd ~; locate */*.pem)
    do
        PEM_ARRAY+=("$item")
    done

    # Append custom choice
    PEM_ARRAY+=("Enter custom path")

    # Ask for pem file
    if [ ${#PEM_ARRAY[@]} -eq 1 ]
    then
        printf "None located.\n"
        CHOSEN_PEM_INDEX=$((${#PEM_ARRAY[@]} - 1))
    else
        for choice in "${!PEM_ARRAY[@]}"
        do
            printf "%s) %s\n" "$choice" "${PEM_ARRAY[$choice]}"
        done

        printf "Choose .pem file location:\n"
        read CHOSEN_PEM_INDEX
    fi

    CHOSEN_PEM="${PEM_ARRAY[$CHOSEN_PEM_INDEX]}"

    # User selected to input custom path, record it
    if [ $CHOSEN_PEM_INDEX -eq $((${#PEM_ARRAY[@]} - 1)) ]
    then
        printf "Type in the path you wish to use: "
        read PEM_PATH
    else
        PEM_PATH="${PEM_ARRAY[$CHOSEN_PEM_INDEX]}"
    fi
}

runSetup

