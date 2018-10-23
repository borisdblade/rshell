#!/usr/bin/env bash

# Reset vars used in loop
resetVars()
{
    CHOICES_ARRAY=()
    CHOSEN_OPTION_INDEX=99
    OLD_PATH_QUESTION="Choose path (num):\n------\n"
    PATH_QUESTION="Choose path (num):\n------\n"
}

# List all instances
listAll()
{
    aws ec2 describe-instances --query "Reservations[*].Instances[*].{name: Tags[?Key=='Name']|[0].Value, state: State.Name, type: InstanceType, PublicIP: PublicIpAddress}|sort_by(@, &[0].name)" --output table --color off
    printf "\nGroups:\n"
    printf "group-pro      # Work with both pro instances.\n"
    printf "group-com      # Work with all .com instances.\n\n"
    exit 1
}

connectOnly()
{
    for IP in $IPS
    do
        printf "${GRN}Connecting to $IP..${NC}\n"
        ssh ubuntu@"$IP" -i ~/.ssh/aws-csa.pem
    done

    printf "${GRN}Done!${NC}\n"
}

connectAndExecute()
{
    # Append project path to command if needed
    if [ $USER_PROJECT_PATH ]; then
        FULL_COMMAND="cd $USER_PROJECT_PATH; $COMMAND; exit"
    else
        FULL_COMMAND="$COMMAND; exit"
    fi

    # Run the command on all selected instances
    for IP in $IPS; do
        printf "\nExecuting ${GRN}${BS}'$FULL_COMMAND'${BE}${NC} @$IP\n\n"
        ssh ubuntu@"$IP" -i "$PEM_PATH" -o ServerAliveInterval="$SERVER_ALIVE_INTERVAL" "$FULL_COMMAND"
        printf "${GRN}Done${NC}\n"
    done
}

connect()
{

    # If we are looking to connect only
    # Otherwise we need to set up the path for given command(s),
    # and only if we are not using custom commands
    if [ $2 -eq 2 ] || [ $ARGS_NUM -eq 1 ] ; then
        # Lift off
        connectOnly
    else
        if ! [ $SET_CUSTOM ]; then
            setPath $1
        fi

        # Lift off
        connectAndExecute

        printf "${GRN}\nScript finished!\n"

        exit 1
    fi
}

executeOnly()
{
    case "$1" in
        rb-cms-update)
            printf "${GRN}Running aws s3 update for rentbits.com cms...${NC}\n"
            OUTPUT=$(aws s3 cp dist s3://rentbits-cms --recursive)
            printf "$OUTPUT"
        ;;
        *)
        ;;
    esac

    printf "${GRN}Done!${NC}\n"
    exit 1
}