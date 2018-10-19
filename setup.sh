#!/usr/bin/env bash

SP_LINE=""
PP_LINE=""

PEM_PATH=~/.ssh/aws-csa.pem
SOURCE_PATH=/Users/gorankrgovic1/Sites/sh

SCRIPT_PATH="/usr/local/bin/rsh"

# Copy main script file to executables folder (SCRIPT_PATH)
installScript()
{
    cp main.sh "$SCRIPT_PATH"
}

addPemPath()
{
    if [ -z "$PEM_PATH" ]
    then
        printf "Enter your .pem file path: "
        read PEM_PATH
        PEM_PATH="PEM_PATH=$PEM_PATH"

        awk 'NR=='"$PP_LINE"'{$0="'"$PEM_PATH"'"}1' config/config.sh > config/config.tmp && mv config/config.tmp config/config.sh
        awk 'NR=='"$PP_LINE_ORG"'{$0="'"$PEM_PATH"'"}1' setup.sh > setup.tmp && mv setup.tmp setup.sh
    fi
}

addSourcePath()
{
    if [ -z "$SOURCE_PATH" ]
    then
        SOURCE_PATH=$(pwd)
        SOURCE_PATH="SOURCE_PATH=$SOURCE_PATH"
        awk 'NR=='"$SP_LINE"'{$0="'"$SOURCE_PATH"'"}1' main.sh > main.tmp && mv main.tmp main.sh
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
    SP_LINE=$(awk '/SOURCE_PATH/{ print NR; exit }' ./main.sh)
    PP_LINE=$(awk '/PEM_PATH/{ print NR; exit }' ./config/config.sh)

    SP_LINE_ORG=$(awk '/SOURCE_PATH/{ print NR; exit }' ./setup.sh)
    PP_LINE_ORG=$(awk '/PEM_PATH/{ print NR; exit }' ./setup.sh)
}

# Setup steps
runSetup()
{
    # Read config file, and find where important lines are
    printf "Defining variables...\n"
    defineConfigLines

    # Add these lines
    printf "Applying variables...\n"
    addConfigLines

    # Copy main script file to executables folder (SCRIPT_PATH)
    printf "Installing script...\n"
    installScript

    # End
    printf "${GRN}Setup done!\n${NC}"
}

runSetup

