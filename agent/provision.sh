#!/bin/bash

# install curl and git
apt-get install -y curl git

# install rvm and ruby
\curl -sSL https://get.rvm.io | bash -s stable
/bin/bash -l -c "rvm requirements"
/bin/bash -l -c "rvm install ruby-2.0.0-p0"
/bin/bash -l -c "rvm use ruby-2.0.0-p0 --default"

# install docker
curl -s https://get.docker.io/ubuntu/ | sh

# setup yarddog-agent
mkdir /src
cd /src
git clone https://github.com/chriskite/yarddog.git
cd yarddog/agent
/bin/bash -l -c "bundle install"
