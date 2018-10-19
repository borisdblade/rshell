#!/usr/bin/env bash
#set -x
SOURCE_PATH=/Users/gorankrgovic1/Sites/sh

# Grab all the passed arguments
ARGS="$@"
ARGS_NUM=$#

# Import project files
source "$SOURCE_PATH/config/config.sh"
source "$SOURCE_PATH/lib/build.sh"
source "$SOURCE_PATH/lib/run.sh"

# Get the param
if [ $# -lt 1 ]; then
    echo $0: "usage: rsh <instance-name> || <instance group>"
    exit 1
fi

# Init the script with passed args
init $ARGS

