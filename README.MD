
Rshell is a tool used to retrieve AWS instances ips by instance name and
connects to selected instance via ssh.

It is useful when your instances are behind AWS Load Balancer.

Connect:

<code>~$ rsh <instance_name></code>

List names:

<code>~$ rsh list </code>


RShell setup

# `install pip3`
-**MAC**-

<code>~$ brew install python3</code>

-**LINUX deb**-

<code>~$ sudo apt install python3</code>

# `install aws client`
-**MAC**-

<code>~$ pip3 install awscli</code>

-**LINUX deb**-

<code>~$ apt install awscli</code> 

 `edit .aws/config `
Or 

<code>~$ aws-configure</code>


[default]
<br>
<code>
aws_access_key_id = <access_key_id>
</code><br>
<code> 
aws_secret_access_key = <secret_access_key>
</code><br>
<code>
region = <your-aws-region>
</code>

 `chmod`

<code>~$ chmod 600 $HOME/.aws/config</code>

 `export environment`

<code>~$ export AWS_CONFIG_FILE=$HOME/.aws/config</code>

 `copy rsh.sh to your Home Directory and make it executable`

<code>~$ sudo chmod +x rsh.sh</code>

 `copy the executable to /usr/local/bin`

<code>~$ sudo cp rsh.sh /usr/local/bin/rsh</code>


 `run the RShell`

<code>~$ rsh <instance_name></code>

 `List instances`

<code>~$ rsh list </code>


**THAT IS IT! ENJOY...**


 `Additional info `

 `aws query ip address for specific instance name`

<code>aws ec2 describe-instances --filters 'Name=tag:Name,Values=<instance-name>' --output text --query 'Reservations[*].Instances[*].PublicIpAddress'</code>

 `command example for extracting instance ip`

<code>aws ec2 describe-instances --filters 'Name=tag:Name,Values=rb-v2-api' --output text --query 'Reservations[*].Instances[*].PublicIpAddress'</code>

 `for later ( generate ssh config`

<code>aws ec2 describe-instances --output text   --query 'Reservations[].Instances[].[Tags[?Key==`Name`,Values==`rb-v2-api`] | [0].Value, PublicIpAddress]'</code>


<code>aws ec2 describe-instances --filters 'Name=tag:Name,Values=dev-server-*' --output text --query 'Reservations[*].Instances[*].InstanceId'</code>
