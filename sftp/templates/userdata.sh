#!/bin/bash

sftp_root_broadvine=${sftp_home}/${sftp_root_broadvine_dir}
sftp_root_mdo=${sftp_home}/${sftp_root_mdo_dir}
sftp_root_mdo_test=${sftp_home}/${mdo_test_user_dir}
sftp_root_mdo_udp=${sftp_home}/${mdo_udp_user_dir}

echo "### Create chroots"
mkdir -p ${sftp_home} && chmod 755 ${sftp_home}
mkdir -p $sftp_root_broadvine && chmod 755 $sftp_root_broadvine
mkdir -p  $sftp_root_mdo && chmod 755 $sftp_root_mdo
mkdir -p  $sftp_root_mdo_test && chmod 755 $sftp_root_mdo_test
mkdir -p  $sftp_root_mdo_udp && chmod 755 $sftp_root_mdo_udp


echo "### Create broadvine subdirectories"
mkdir -p $sftp_root_broadvine/Outbound
mkdir -p $sftp_root_broadvine/Outbound/ERP/Actual
mkdir -p $sftp_root_broadvine/Outbound/myPlan/myPlan\ Budget
mkdir -p $sftp_root_broadvine/Outbound/myPlan/myPlan\ Forecast

echo "### Create mdo shared subdirectories"
mkdir -p $sftp_root_mdo/YDM

echo "### Create mdo test subdirectories"
mkdir -p $sftp_root_mdo_test/MAR

echo "### Create mdo udp subdirectories"
mkdir -p $sftp_root_mdo_udp/Outbound
mkdir -p $sftp_root_mdo_udp/Outbound/Trend
mkdir -p $sftp_root_mdo_udp/Outbound/Ledger
mkdir -p $sftp_root_mdo_udp/Outbound/Plan
mkdir -p $sftp_root_mdo_udp/Outbound/Balance
mkdir -p $sftp_root_mdo_udp/Outbound/ERP
mkdir -p $sftp_root_mdo_udp/Outbound/ERP/Actual
mkdir -p $sftp_root_mdo_udp/Outbound/ABC
mkdir -p $sftp_root_mdo_udp/Outbound/XYZ
mkdir -p $sftp_root_mdo_udp/Inbound
mkdir -p $sftp_root_mdo_udp/Archive
mkdir -p $sftp_root_mdo_udp/Backup
mkdir -p $sftp_root_mdo_udp/Common
mkdir -p $sftp_root_mdo_udp/Share
mkdir -p $sftp_root_mdo_udp/Share/ABC
mkdir -p $sftp_root_mdo_udp/Share/XYZ
mkdir -p $sftp_root_mdo_udp/MDO
mkdir -p $sftp_root_mdo_udp/MDO/XYZ
mkdir -p $sftp_root_mdo_udp/MDO/YDM
mkdir -p $sftp_root_mdo_udp/PMS
mkdir -p $sftp_root_mdo_udp/Temp

echo "### Create sftp user"
useradd -p $(openssl passwd -1 "${sftp_pass}") "${sftp_user}"
useradd -p $(openssl passwd -1 "${mdo_pass}") "${mdo_user}"
useradd -p $(openssl passwd -1 "${mdo_test_pass}") "${mdo_test_user}"
useradd -p $(openssl passwd -1 "${mdo_udp_pass}") "${mdo_udp_user}"

echo "### Change ownership"
chown -R ${sftp_user}:ubuntu $sftp_root_broadvine/*
chown -R ${mdo_user}:ubuntu $sftp_root_mdo/*
chown -R ${mdo_test_user}:ubuntu $sftp_root_mdo_test/*
chown -R ${mdo_udp_user}:ubuntu $sftp_root_mdo_udp/*

echo "### Set write permission to ubuntu user"
chmod -R g+w $sftp_root_broadvine/*
chmod -R g+w $sftp_root_mdo/*
chmod -R g+w $sftp_root_mdo_test/*
chmod -R g+w $sftp_root_mdo_udp/*

echo "### Restricting SFTP user access to directory"
tee -a /etc/ssh/sshd_config << EOF
Match User ${sftp_user}
        ForceCommand internal-sftp
        PasswordAuthentication yes
        ChrootDirectory $sftp_root_broadvine
        PermitTunnel no
        AllowAgentForwarding no
        AllowTcpForwarding no
        X11Forwarding no

Match User ${mdo_user}
        ForceCommand internal-sftp
        PasswordAuthentication yes
        ChrootDirectory $sftp_root_mdo
        PermitTunnel no
        AllowAgentForwarding no
        AllowTcpForwarding no
        X11Forwarding no

Match User ${mdo_test_user}
        ForceCommand internal-sftp
        PasswordAuthentication yes
        ChrootDirectory $sftp_root_mdo_test
        PermitTunnel no
        AllowAgentForwarding no
        AllowTcpForwarding no
        X11Forwarding no

Match User ${mdo_udp_user}
        ForceCommand internal-sftp
        PasswordAuthentication yes
        ChrootDirectory $sftp_root_mdo_udp
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