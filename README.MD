Rshell is a tool used to retrieve AWS instances ips by instance name, connect to them,
execute custom or predefined commands on instances...

It is useful when your instances are behind AWS Load Balancer.

**RShell setup**

**`IF YOU HAVE PYTHON AND AWS SET UP ALREADY, SKIP TO STEP`**[#3](#3.deployment#)
# 1. install pip3 #

Mac:

    brew install python3

Linux deb:

    sudo apt install python3

# 2. Install aws client #
 
Mac:

    pip3 install awscli

Linux deb:

    apt install awscli 

Edit .aws/config, or

    aws-configure

.aws/config example
   
    [default]
    aws_access_key_id = <access_key_id> 
    aws_secret_access_key = <secret_access_key>
    region = <your-aws-region>

Chmod

     chmod 600 $HOME/.aws/config

Export environment

     export AWS_CONFIG_FILE=$HOME/.aws/config

# 3.Deployment #

    Download or clone this project
    
And make main file executable

    sudo chmod +x rsh.sh

# 4.Setup RSH #

Run the setup from the root of project directory

    sh setup.sh

# 5.Options #

List instances

    rsh list
    
Connect:

    rsh <instance_name>

Run custom commands:

    rsh <instance_name> -custom="cd /var/www/example; touch hello.php;"

Run predefined commands:

    rsh <instance_name> -git
    
Predefined commands:
    
    -git        # git pull
    -composer   # composer install; composer du
And more to come!

**THAT IS IT! ENJOY...**


**Additional info**

aws query ip address for specific instance name

    aws ec2 describe-instances --filters 'Name=tag:Name,Values=<instance-name>' --output text --query 'Reservations[*].Instances[*].PublicIpAddress'

command example for extracting instance ip

    aws ec2 describe-instances --filters 'Name=tag:Name,Values=rb-v2-api' --output text --query 'Reservations[*].Instances[*].PublicIpAddress'

for later :: generate ssh config

    aws ec2 describe-instances --output text   --query 'Reservations[].Instances[].[Tags[?Key==`Name`,Values==`rb-v2-api`] | [0].Value, PublicIpAddress]'


    aws ec2 describe-instances --filters 'Name=tag:Name,Values=dev-server-*' --output text --query 'Reservations[*].Instances[*].InstanceId'
