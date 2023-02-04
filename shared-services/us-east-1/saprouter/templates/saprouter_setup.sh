zypper update -y 
zypper --non-interactive --ignore-unknown --no-gpg-checks --no-cd install --auto-agree-with-licenses --allow-unsigned-rpm https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl daemon-reload
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

mkdir -p ${ROUTDIR}/install
aws s3 sync  s3://${BUCKET} ${ROUTDIR}/install
cd  ${ROUTDIR}/install
# All files will become lowe case files
for f in `find`; do mv -v "$f" "`echo $f | tr '[A-Z]' '[a-z]'`"; done
chmod u+x ${ROUTDIR}/install/${SAPCAR}
mv ${SERVICE} /etc/systemd/system/${SERVICE}
for f in `find . -name saprouter*.sar`; do mv -v $f saprouter.sar; done
for f in `find . -name sapcryptolib*.sar`; do mv -v $f sapcryptolib.sar; done
for f in `find . -name sapcar*`; do mv -v $f sapcar; done
chmod u+x sapcar
mv saprouttab ..
cd ${ROUTDIR}
./install/sapcar -xf ${ROUTDIR}/install/saprouter.sar
./install/sapcar -xf ${ROUTDIR}/install/sapcryptolib.sar

## Start the Service 
systemctl daemon-reload
systemctl enable ${SERVICE}
systemctl start ${SERVICE}

