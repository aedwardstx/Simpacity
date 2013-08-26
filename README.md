#Overview
Simpacity is a Rails 4 based network link capacity management application built to satisfy the basic requirements of an enterprise.  This project is currently in development and is being tested on production data.  It works by analyzing thousands of time series records to create trends based on a [Simple Linear Regression Trending Algorithm](http://en.wikipedia.org/wiki/Simple_linear_regression).  It has support for interface-groups(Shared Risk Link Groups), threshold alerting, auto-discovery of interfaces and devices, HighCharts graphing, Devise based LDAP authentication, and more to come.  Please feel free to reach out to me if you have any questions concerning the project.

##Dependencies:
A successful installation of calmh's zpoller with packages.yml(sample file provided) and general.yml(defaults probably ok) configured to your liking.  Simpacity will take care of the hosts.csv file and issuing zconfig upon changes.  Zpoller does not come with an init script, a Debian compatible one is provided by this project. Simpacity must have permissions to write the hosts.csv file.


#Simpacity Installation

##Install required Debian packages
```
sudo apt-get install build-essential sysstat snmp mongodb git-core curl build-essential openssl libssl-dev ruby1.9.1-dev
```

##Install nodejs
```
git clone https://github.com/joyent/node.git  
cd node  
```
`git tag` -- shows all available versions: select the latest stable.  
```
git checkout v0.10.16  
./configure  
make  
make test  
sudo make install
```

##Install Zpoller   ---  Need to document this / reference the docs to this
Example zpoller config files and an init script can be found in the ./docs/zpoller directory.

#Install Rails and setup Simpacity
```
sudo gem install rails  
sudo gem install mongo  
sudo gem install bson_ext
```

##Changes to Simpacity to suite your environment
Correct the path for SimpactiyMath in Gemfile
Correct the path for simpacity_base in all ./lib/Simpacity.* files
Change the database.yaml file to suite your environment
Change the ldap.yaml configuration file to meet your needs
```
bundle  
bundle install  
./bin/rake db:migrate  
./bin/rake db:seed  
ln-s /path_to_simpacity/lib/zpoller-init.sh /etc/init.d/zpoller  
sudo update-rc.d zpoller start 99 2 3 4 5 stop 01 0 1 6
```

##Setup the cron scripts
An example cron script is provided under ./lib/simpacity.cron 

##Install and configure your favorite ruby application server
This will not be documented here but should be pretty straight forward.
 
#Getting started with Simpacity once installed
1. Review the General Settings page and make corrections to the default settings.
2. Configure an SNMP community
3. Configure a device
4. Configure an interface
5. Verify the poller health from the devices and interfaces pages
6. If everything is working properly, you should see statistics on the per_link statistics page.
