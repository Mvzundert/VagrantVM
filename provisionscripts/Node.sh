#!/usr/bin/env bash

# This provision script installs Node, Bower,

# install the missing libs
sudo yum install -y  gcc gcc-c++  libtool-ll libtool-ltdl-devel lsof make unixODBC unixODBC-devel wget

# install Node
sudo yum install -y nodejs npm --enablerepo=epel

# install Grunt, Gulp Bower
npm install -g grunt grunt-cli gulp bower
