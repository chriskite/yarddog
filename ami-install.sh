#!/bin/bash
# should be root
[ $EUID != 0 ] && exit 1
useradd -m -g users -G docker -s /bin/bash yarddog
sudo -u yarddog <<YARDDOG
curl -sSL https://get.rvm.io | bash -s stable --ruby
source .rvm/scripts/rvm
gem install -N commander fog highline inifile rake sinatra rest-client docker-api
YARDDOG
curl -sSL https://get.docker.io/gpg | apt-key add -
echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install lxc-docker
echo 'DOCKER_OPTS="-H tcp://0.0.0.0:60186 -H unix:///var/run/docker.sock"' >> /etc/default/docker
