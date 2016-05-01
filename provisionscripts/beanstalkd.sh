#!/usr/bin/env bash

# Clone the repo
git clone git://github.com/kr/beanstalkd.git

# Move into the directory
cd beanstalkd

make

cp beanstalkd /usr/bin/beanstalkd
mkdir /var/lib/beanstalkd

#Create file /etc/systemd/system/beanstalkd.service with this content:
cat > etc/systemd/system/beanstalkd.service <<EOF
[Unit]
Description=Beanstalkd is a simple, fast work queue

[Service]
User=root
ExecStart=/usr/bin/beanstalkd -b /var/lib/beanstalkd

[Install]
WantedBy=multi-user.target
EOF

# turn it on.
systemctl enable beanstalkd and systemctl start beanstalkd