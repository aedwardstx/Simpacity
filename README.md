Simpacity is a simple Rails 4 based link capacity management system built to satisfy the basic requirements of an enterprise.  This project is currently in development and has not been tested in production.  It works by analyzing thousands of time series records to create trends based on a simple linear regression algorithm.  It has support for interface-groups(Shared Risk Link Groups), threshold alerting, auto-addition of interfaces and devices, HighCharts graphing, and more to come.   

Dependencies: 
A successful installation of zpoller with packages.yml(must collect ifInOctets and ifOutOctets from a network device via SNMP) and general.yml configured to your liking.  Simpacity will take care of the hosts.csv file.  Zpoller does not come with an init script, you will have to create one.  Simpacity must have permissions to re-write the hosts.csv file.   
MongoDB, Ruby >1.9.3, Node.js

