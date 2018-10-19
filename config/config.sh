#!/usr/bin/env bash

PEM_PATH=~/.ssh/aws-csa.pem
SOURCE_PATH=/Users/gorankrgovic1/Sites/sh

SETUP_ACTIVE=0

OPTIONS=""
IPS=""
COMMAND=""
FULL_COMMAND=""

SET_CUSTOM=""
CUSTOM_COMMAND=""
USER_PROJECT_PATH=""

SERVER_ALIVE_INTERVAL=120
CUSTOM_PATH_INDEX=99

CONNECT_ONLY=1

FOUND_PATHS=""
CHOSEN_OPTION_INDEX=99
OLD_PATH_QUESTION="Select path (num):"
PATH_QUESTION="Select path (num):"

GROUPS_SELECT=""

ASK_AGAIN=1
CHOOSE_FOR_ALL=0

CHOICES_ARRAY=()

# Colors
GRN="\033[0;32m"
# No color
NC="\033[0m"

# Bold start
BS=$(tput bold)
# Bold end
BE=$(tput sgr0)
