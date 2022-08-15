#!/bin/bash

echo "### Create chroots"
mkdir -p ${sftp_root} && chmod 755 ${sftp_root}
mkdir -p  ${sftp_root_mdo} && chmod 755 ${sftp_root_mdo}

echo "### Create shared directories"
mkdir -p ${sftp_root}/Outbound
mkdir -p ${sftp_root}/Outbound/ERP/Actual
mkdir -p ${sftp_root}/Outbound/myPlan/myPlan\ Budget

echo "### Create mdo shared dir"
mkdir -p ${sftp_root_mdo}/YDM

echo "### Create sftp user"
useradd -p $(openssl passwd -1 "${sftp_pass}") "${sftp_user}"
useradd -p $(openssl passwd -1 "${mdo_pass}") "${mdo_user}"

echo "### Change ownership"
chown -R ${sftp_user}:${sftp_user} ${sftp_root}/*
chown -R ${mdo_user}:${mdo_user} ${sftp_root_mdo}/*

echo "### Restricting SFTP user access to directory"
tee -a /etc/ssh/sshd_config << EOF
Match User ${sftp_user}
        ForceCommand internal-sftp
        PasswordAuthentication yes
        ChrootDirectory ${sftp_root}
        PermitTunnel no
        AllowAgentForwarding no
        AllowTcpForwarding no
        X11Forwarding no

Match User ${mdo_user}
        ForceCommand internal-sftp
        PasswordAuthentication yes
        ChrootDirectory ${sftp_root_mdo}
        PermitTunnel no
        AllowAgentForwarding no
        AllowTcpForwarding no
        X11Forwarding no

EOF

echo "### Restart sshd service"
systemctl restart sshd




#SSM Agent installation
mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent