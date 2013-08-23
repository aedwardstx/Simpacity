Simpacity is a simple Rails 4 based link capacity management system built to satisfy the basic requirements of an enterprise.  This project is currently in development and has not been tested in production.  It works by analyzing thousands of time series records to create trends based on a simple linear regression algorithm.  It has support for interface-groups(Shared Risk Link Groups), threshold alerting, auto-addition of interfaces and devices, HighCharts graphing, and more to come.   

Dependencies: 
A successful installation of calmh's zpoller with packages.yml(must collect ifInOctets and ifOutOctets from a network device via SNMP) and general.yml configured to your liking.  Simpacity will take care of the hosts.csv file and issuing zconfig upon changes.  Zpoller does not come with an init script, you will have to create one(one will be provided by this project in the future).  Simpacity must have permissions to re-write the hosts.csv file. 
  
MongoDB, Ruby >1.9.3, Node.js



#Simpacity Installation

#Install required Debian packages
sudo apt-get install build-essential sysstat snmp mongodb git-core curl build-essential openssl libssl-dev ruby1.9.1-dev

#Install Zpoller   ---  Need to add this


#Install nodejs  
git clone https://github.com/joyent/node.git
cd node

# 'git tag' shows all available versions: select the latest stable.
git checkout v0.10.16
 
# Configure seems not to find libssl by default so we give it an explicit pointer.
# Optionally: you can isolate node by adding --prefix=/opt/node
./configure --openssl-libpath=/usr/lib/ssl
make
make test
sudo make install



#Install Rails and setup Simpacity
sudo gem1.9.1 install rails
sudo gem install mongo
sudo gem install bson_ext

change path for SimpactiyMath in Gemfile
change path for simpacity_base in all ./lib/Simpacity.* files
  
bundle
bundle install

./bin/rake db:migrate
./bin/rake db:seed



ln-s /path_to_simpacity/lib/zpoller-init.sh /etc/init.d/zpoller
sudo update-rc.d zpoller start 99 2 3 4 5 stop 01 0 1 6

