Installation and Preliminary Operations
=======================================

Installation Requirements
-------------------------

### System Requiremenets

+ RHEL 6.x

### Network Requirements

+ Local Area Network (LAN)
+ Internet connection

### yum pre-estup

Downloading repo file and put it to your /etc/yum.repos.d/ repository.

    # curl -o /etc/yum.repos.d/wakame-vdc.repo -R https://raw.github.com/axsh/wakame-vdc/master/rpmbuild/wakame-vdc.repo
    # curl -o /etc/yum.repos.d/openvz.repo     -R https://raw.github.com/axsh/wakame-vdc/master/rpmbuild/openvz.repo

Installing epel-release.

    # yum install http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/i386/epel-release-6-7.noarch.rpm

### Dcmgr Installation

    # yum install wakame-vdc-dcmgr-vmapp-config

### Hva installation

    # yum install wakame-vdc-hva-full-vmapp-config


Configuring upstart system job
-------------------------------

Comment out to run upstart system jobs in /etc/default/vdc-*.

    #RUN=yes

+ dcmgr node
  + /etc/default/vdc-collector
  + /etc/default/vdc-dcmgr
  + /etc/default/vdc-proxy
  + /etc/default/vdc-webui
  + /etc/default/vdc-auth
  + /etc/default/vdc-metadata
  + /etc/default/vdc-nsa
  + /etc/default/vdc-sta
+ hva node
  + /etc/default/vdc-hva


Pre-setup Dcmgr
----------------

### dcmgr(endpoints)

    # cp -f /opt/axsh/wakame-vdc/dcmgr/config/dcmgr.conf.example /etc/wakame-vdc/dcmgr.conf

### webui

    # cp -f /opt/axsh/wakame-vdc/frontend/dcmgr_gui/config/database.yml.example      /etc/wakame-vdc/dcmgr_gui/database.yml
    # cp -f /opt/axsh/wakame-vdc/frontend/dcmgr_gui/config/dcmgr_gui.yml.example     /etc/wakame-vdc/dcmgr_gui/dcmgr_gui.yml
    # cp -f /opt/axsh/wakame-vdc/frontend/dcmgr_gui/config/instance_spec.yml.example /etc/wakame-vdc/dcmgr_gui/instance_spec.yml

### pre-setup proxy

    # echo "$(eval "VDC_ROOT=/var/lib/wakame-vdc; echo \"$(curl -s https://raw.github.com/axsh/wakame-vdc/master/tests/vdc.sh.d/proxy.conf.tmpl)\"")" > /etc/wakame-vdc/proxy.conf


Pre-setup Hva
--------------

    # cp -f /opt/axsh/wakame-vdc/dcmgr/config/hva.conf.example /etc/wakame-vdc/hva.conf


Configuring Database
--------------------

The database to use is specified in a configuration file.

### dcmgr(endpoints)

    database_uri 'mysql2://localhost/wakame_dcmgr?user=root'

+ /etc/wakame-vdc/dcmgr.conf

### webui

    development:
       adapter: mysql2
       database: wakame_dcmgr_gui
       host: localhost
       user: root
       password:

+ /etc/wakame-vdc/dcmgr_gui/database.yml


Configuring AMQP Server
-----------------------

The amqp server to use is specified in a configuration file.

### dcmgr(endpoints)

    amqp_server_uri 'amqp://localhost/'

+ /etc/wakame-vdc/dcmgr.conf

### agents (collector, hva, etc.)

    #AMQP_ADDR=127.0.0.1
    #AMQP_PORT=5672

+ /etc/default/vdc-collector
+ /etc/default/vdc-hva
+ /etc/default/vdc-nsa
+ /etc/default/vdc-sta


Creating Database
-----------------

    # for dbname in wakame_dcmgr wakame_dcmgr_gui; do
      mysqladmin -uroot create ${dbname}
    done

    # export PATH=$PATH:/opt/axsh/wakame-vdc/ruby/bin
    # cd /opt/axsh/wakame-vdc/dcmgr
    # bundle exec rake db:init
    # cd /opt/axsh/wakame-vdc/frontend/dcmgr_gui
    # bundle exec rake db:init db:sample_data oauth:create_table


Developer Zone
==============

Installing RPM Builder Software
-------------------------------

### Donwloading Wakame-VDC

    # git clone git://github.com/axsh/wakame-vdc.git

### Installing Base Packages to Build RPMs

vdc.sh installs base packages to build RPMs.

    # cd ./wakame-vdc/
    # ./tests/vdc.sh install::rhel

Building Wakame-VDC RPMs
------------------------

### Building RPMs using Makefile

rules is GNU Makefile. this is based on debian/rule.

    # ./rpmbuild/rules binary

Installing Wakame-VDC RPMs
--------------------------

    # yum install /root/rpmbuild/RPMS/x86_64/wakame-vdc-*.rpm

Developing Wakame-VDC RPMs
--------------------------

### Deploying Wakame-VDC

    $ [ -d ~/rpmbuild/BUILD/ ] || mkdir -p ~/rpmbuild/BUILD/
    $ cd ~/rpmbuild/BUILD/
    $ git clone git://github.com/axsh/wakame-vdc.git wakame-vdc-12.03
    $ cd wakame-vdc-12.03

### Modifying files.

    $ vi ./path/to/file...

#### Building RPMs using SPEC.

    $ rpmbuild -bc --short-circuit ./rpmbuild/SPECS/wakame-vdc.spec
    $ rpmbuild -bb --short-circuit ./rpmbuild/SPECS/wakame-vdc.spec
