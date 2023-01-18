#!/bin/bash

#aws cli installation
echo '### Installing aws cli'
apt install zip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install

#Attach EBS
echo '### Attaching EBS'
instance_id=`curl -s http://169.254.169.254/latest/meta-data/instance-id/`
echo $instance_id
sleep 120 # wait till the volume is released from any old instance
aws ec2 attach-volume --volume-id ${vol_id} --instance-id $instance_id --device /dev/sdf


#Mount EBS
echo '### Mounting EBS'
sleep 10
ls /dev/nvme1n1
lsblk | grep nvme1n1p1 || echo -e 'o\nn\np\n1\n\n\nw' | sudo fdisk /dev/nvme1n1
blkid | grep nvme1n1p1 | grep ext4 || sudo mkfs.ext4 /dev/nvme1n1p1
sudo mkdir -p ${sftp_home}
echo "/dev/nvme1n1p1 ${sftp_home} ext4 defaults,comment=cloudconfig 0 2" | sudo tee -a /etc/fstab
sudo mount -a

#Attach EIP
echo '### Associating EIP.'
echo "allocation ID is ${eip_aid}"
aws ec2 associate-address --instance-id $instance_id --allocation-id ${eip_aid}

#SFTP
echo "### Installing jq"
apt install jq -y
sftp_settings=${sftp_settings}
echo $sftp_settings


#Creating sftp_home
mkdir -p ${sftp_home} && chmod 755 ${sftp_home}


echo "### Create sftp user"
usercount=`echo $sftp_settings | jq -c -r .sftp_settings[].username | wc -w`
for (( i=0; i<$usercount; i++))
do
        username=`echo $sftp_settings | jq -r .sftp_settings[$i].username`
        password=`echo $sftp_settings | jq -r .sftp_settings[$i].password`
        user_home=`echo $sftp_settings | jq -r .sftp_settings[$i].user_home`
        sub_dirs=`echo $sftp_settings | jq  -c -r .sftp_settings[$i].sub_dirs | tr -d '[' | tr -d ']' | tr -d '"' | sed 's/,/\n/g' | sed 's/^/./g'`
        echo "### Creating $username with password $password"
        useradd -p $(openssl passwd -1 "$password") "$username"

        echo "### Creating user home $user_home for $username"
        mkdir -p ${sftp_home}/$user_home


        echo "### Lising sub directories for $username"
        echo $sub_dirs

        echo "### Creating subdirectories for $username"
        cd ${sftp_home}/$user_home
        mkdir -p $sub_dirs
        
        echo "### Changing ownership of sftp directories for $username"
        chown -R $username:ubuntu ${sftp_home}/$user_home/*

        echo "### Setting write permission to ubuntu user on $username s directories"
        chmod -R g+w ${sftp_home}/$user_home/*

        echo "### Restricting SFTP user access to ${sftp_home}/$user_home directory for $username"
        tee -a /etc/ssh/sshd_config << EOF
Match User $username
        ForceCommand internal-sftp
        PasswordAuthentication yes
        ChrootDirectory ${sftp_home}/$user_home
        PermitTunnel no
        AllowAgentForwarding no
        AllowTcpForwarding no
        X11Forwarding no
EOF

done

echo "### Restart sshd service"
systemctl restart sshd


#SSM Agent installation
mkdir /tmp/ssm
cd /tmp/ssm
wget -q https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent

### CLOSURE
echo '### Userdata script completed!!!'