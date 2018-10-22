#!/usr/bin/env bash

OLD_PATH_QUESTION="Select path (num):"
PATH_QUESTION="Select path (num):"

# Unify commands
unifyCommand()
{
    if [ $SET_CUSTOM ]; then
        COMMAND="$CUSTOM_COMMAND"
    else
        COMMAND="$OPTIONS"
    fi
}

# Git or composer options passed?
setOption()
{
    case "$1" in
        git)
        # Append to options
        if [ ! -z "$OPTIONS" -a "$OPTIONS" != " " ] ; then
            OPTIONS="$OPTIONS; git pull"
        else
            OPTIONS="git pull"
        fi
        ;;
        composer)
        # Append to options
        if [ ! -z "$OPTIONS" -a "$OPTIONS" != " " ] ; then
            OPTIONS="$OPTIONS; composer install; composer du"
        else
            OPTIONS="composer install; composer du"
        fi
        ;;
        *)
        ;;
    esac
}

# Needed as a method because of possible recursion
# Check if we want selected path for all instances
# Called only when working with group IP addresses
checkChooseForAll()
{
    # We are working with groups, ask if we need to use this path for all instances
    if [ $1 -gt 1 ]
    then
        printf "\nUse this path for all current-command instances? (y/n):"
        read SAME_PATH

        # Use same path for all instances
        if [ "$SAME_PATH" == "y" ] || [ "$SAME_PATH" == "" ]
        then
            CHOOSE_FOR_ALL=1
        elif [ "$SAME_PATH" == "n" ]
        then
            CHOOSE_FOR_ALL=0
        else
            # Something else was picked, recurse it
            checkChooseForAll $1
        fi
    fi
}

choosePath()
{
    # Resetting the variables needed here cause we are in for loop one level above this method
    resetVars
    # Connection IP
    IP=$1
    # Set groups local var
    local GROUPS=$2

    # Find path of all .git files where we have permission to read
    FOUND_PATHS=$(ssh ubuntu@"$IP" -i "$PEM_PATH" -o ServerAliveInterval="$SERVER_ALIVE_INTERVAL" "find /var -type d -name .git -prune 2>&1 | grep -v 'Permission denied'")

    # Loop them because of groups; can have multiple instances (ips)
    # Parse data to array
    for var in $FOUND_PATHS
    do
        # Remove the .git file suffix from path
        APPEND=${var%".git"}

        # Append to array where are all the paths to a git projects
        CHOICES_ARRAY+=("$APPEND")
    done

    # Append the option for the custom path
    CHOICES_ARRAY+=("Enter custom path")

    # Print the choices of paths until we select a viable one
    while ! [ "$CHOSEN_OPTION_INDEX" -ge 0 ] 2>/dev/null || ! [ $CHOSEN_OPTION_INDEX -lt ${#CHOICES_ARRAY[@]} ] 2>/dev/null;
    do
        # Output question
        printf "All viable paths:\n-----\n"

        # Output choices
        for choice in "${!CHOICES_ARRAY[@]}"
        do
            printf "%s) %s\n" "$choice" "${CHOICES_ARRAY[$choice]}"
        done

        # Read user choice for path
        printf "$PATH_QUESTION"
        read CHOSEN_OPTION_INDEX


        # If we repeat this, option was invalid. Append the error info to output variable for the next iteration
        PATH_QUESTION="\nInvalid choice!\n$OLD_PATH_QUESTION"
    done

    # User selected to input custom path, record it
    if [ $CHOSEN_OPTION_INDEX -eq $((${#CHOICES_ARRAY[@]} - 1)) ]
    then
        printf "Type in the path you wish to use: "
        read USER_PROJECT_PATH
    else
        USER_PROJECT_PATH="${CHOICES_ARRAY[$CHOSEN_OPTION_INDEX]}"
    fi

    # Might be useful for server groups
#    checkChooseForAll $GROUPS
}

# Set path where wanted command should be executed
setPath()
{
    for IP in $IPS; do
        # Ask the user for path
        choosePath "$IP" $1
        # For now we only use single path for all the instances, so break right after first
        break;
    done
}

setIps()
{
    IPS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$1" --output text  --query "Reservations[*].Instances[*].PublicIpAddress")
}

setInstance()
{
    # Set ip addresses based on selection (group or single instance)
    case "$1" in
        # Group 'pro'
        pro)
            setIps "*v2-pro*"
            ;;
        # Group 'com'
        com)
            setIps "*rentbits-ubuntu*"
            ;;
        # Everything else is considered instance name literal
        *)
            setIps "$1"
            ;;
    esac
}

setCustomCommand()
{
    CUSTOM_COMMAND="$CUSTOM_COMMAND $1"
}

checkInstanceType()
{
    case "$ARGS" in
        *group-pro*)
            setInstance pro
        ;;
        *group-com*)
            setInstance com
        ;;
        *)
            for i in $ARGS; do
                setInstance "$i"
                break;
            done
        ;;
    esac
}

checkCommands()
{
    for var in $ARGS
    do
        case $var in
            # List all aws instances
            list)
                listAll
            ;;
            # Add git pull
            -git)
                setOption git
            ;;
            # Add composer install and composer du
            -composer)
                setOption composer
            ;;
        esac
        shift
    # Loop done
    done
}

# First we need to check if user is trying to use custom command
checkCustomCommand()
{
    # Check if custom command
    case "$ARGS" in
        *-custom*)
            SET_CUSTOM=true
            setCustomCommand "${ARGS#*-custom=}"
        ;;
        *)
        ;;
    esac
}

checkIpValues()
{
    if [ -z "$IPS" ]
    then
        printf "\nInvalid connection passed, please retry.\n"
        exit 1
    fi
}


run()
{
    # Unify custom and predefined commands
    unifyCommand
    # Lift off
    connect $1 $2
}


# ------------------------------- #
# -------- Init Method ---------- #
# ------ The Start Itself ------- #
# ------------------------------- #
init()
{
    printf "${GRN}Collecting data...${NC}\n"

    # Are we working with GROUPS?
    # Same for CONNECT_ONLY
    # 1 => not
    # 2 => yes
    local GROUP=1
    local CONNECT_ONLY=1

    # Are we passing custom command?
    checkCustomCommand

    # Group OR single instance
    checkInstanceType

    # Check which commands are passed, if any
    checkCommands


    # Check if we have valid IPS collected
    checkIpValues

    # Flag the instance type (locally)
    case "$ARGS" in
        *group-pro* | *group-com*)
            local GROUP=2
            ;;
        *)
            ;;
    esac

    run $GROUP $CONNECT_ONLY
}
