Introduction
------------
Vagrant and Puppet resources for setting up a serverspec in Virtual Box with running Puppet
as covered in [Testing Puppet modules with Vagrant and ServerSpec] (https://engineering.opendns.com/2014/11/13/testing-puppet-modules-vagrant-serverspec/)
First Puppet 3.8.1 is installed on guest(s) by running shell provioner.
Then manifest `step{1,2,3}.pp` is applied to guest(s). Finally serverspec is run.
Environment
-----------
Based on the `BOX_NAME` environment the following guest is created 

 - ubuntu 12.04 32 and 64
 - ubuntu 14.04 32 and 64
 - centos65
 - centos7
 - windows7

Note
----
Puppet rabbitmq module seems to be not very stable. Currently the only working configuration is with trusty64 pupperlabs-rabbitmq 4.0.0 and puppet 3.8.1 
Serverspec requires rspec `3.3.0`. Remove all older revisions or `rspec-expectations` from the host

