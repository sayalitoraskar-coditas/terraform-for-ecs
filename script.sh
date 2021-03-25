#! /bin/bash
sudo yum update -y
#sudo yum install httpd -y
#sudo systemctl start httpd
sudo mkdir abcd
sudo echo 'ECS_CLUSTER=${name}' >> /etc/ecs/ecs.config
