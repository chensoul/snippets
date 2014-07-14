#!/bin/sh

apt-get remove ruby1.9.1
#curl -L get.rvm.io | bash -s stable
. ~/.bashrc
.  ~/.bash_profile
sed -i -e 's/ftp\.ruby-lang\.org\/pub\/ruby/ruby\.taobao\.org\/mirrors\/ruby/g' ~/.rvm/config/db

rvm install 1.9.3
rvm use 1.9.3  --default

gem install jekyll rdiscount redcarpet
