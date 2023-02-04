#!/bin/bash

## Update the software and install the S3 Fuse application 
yum update -y 
amazon-linux-extras install epel -y
yum install s3fs-fuse -y

mkdir /sftp
chown root:root /sftp 
chmod 0755 /sftp 

%{ for shares in sftp_shares }
useradd ${ shares.username }
mkdir -p /sftp/${ shares.username }/${ shares.mount }
chown root:root /sftp/${ shares.username } 
chmod 0755 /sftp/${ shares.username } 

chown ${ shares.username }:${ shares.username } /sftp/${ shares.username }/${ shares.mount }

echo '${ shares.bucket }:${ shares.bucket_prefix } /sftp/${ shares.username }/${ shares.mount } fuse.s3fs _netdev,allow_other,iam_role=${ instance_profile },uid=${ shares.username },gid=${ shares.username } 0 0' >> /etc/fstab
cat << EOA >> /etc/ssh/sshd_config 
# Start block ${ shares.username }
Match User ${ shares.username }
    ForceCommand internal-sftp
    PasswordAuthentication yes
    ChrootDirectory /sftp/${ shares.username }
    PermitTunnel no
    AllowAgentForwarding no
    AllowTcpForwarding no
    X11Forwarding no
# End block ${ shares.username }

EOA
%{ endfor }

mount -a
systemctl restart sshd
