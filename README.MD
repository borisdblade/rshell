Rshell is a tool used to retrieve AWS instances ips by instance name and
connects to selected instance via ssh.

It is useful when your instances are behind AWS Load Balancer.

Connect:

    rsh <instance_name>

List names:

    rsh list


**RShell setup**

Install pip3

Mac:

    brew install python3

Linux deb:

    sudo apt install python3

Install aws client
 
Mac

    pip3 install awscli

Linux deb

    apt install awscli 

Edit .aws/config, or

    aws-configure

.aws/config example
   
    [default]
    aws_access_key_id = <access_key_id> 
    aws_secret_access_key = <secret_access_key>
    region = <your-aws-region>

chmod

     chmod 600 $HOME/.aws/config

export environment

     export AWS_CONFIG_FILE=$HOME/.aws/config

copy rsh.sh to your Home Directory and make it executable

    sudo chmod +x rsh.sh

copy the executable to /usr/local/bin

    sudo cp rsh.sh /usr/local/bin/rsh


Run RShell

    rsh <instance_name>

List instances

    rsh list


**THAT IS IT! ENJOY...**


**Additional info**

aws query ip address for specific instance name

    aws ec2 describe-instances --filters 'Name=tag:Name,Values=<instance-name>' --output text --query 'Reservations[*].Instances[*].PublicIpAddress'

command example for extracting instance ip

    aws ec2 describe-instances --filters 'Name=tag:Name,Values=rb-v2-api' --output text --query 'Reservations[*].Instances[*].PublicIpAddress'

for later :: generate ssh config

    aws ec2 describe-instances --output text   --query 'Reservations[].Instances[].[Tags[?Key==`Name`,Values==`rb-v2-api`] | [0].Value, PublicIpAddress]'


    aws ec2 describe-instances --filters 'Name=tag:Name,Values=dev-server-*' --output text --query 'Reservations[*].Instances[*].InstanceId'
