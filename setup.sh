#!/bin/bash
# Install pip and some python modules needed by OAuth2 auth plugin
# also install oauth2-auth-plugin and simple-browser
apt-get -y update
apt-get -y  --force-yes install python-pip git wget unzip
pip install paver
cd /web/plugins/
wget https://github.com/boundlessgeo/qgis-server-oauth2-auth-plugin/archive/master.zip
unzip master.zip
rm master.zip
cd qgis-server-oauth2-auth-plugin-master/
paver setup
cd ..
wget https://github.com/elpaso/qgis-server-simple-browser/archive/master.zip
unzip master.zip
rm master.zip
# Fix permissions on certificates
find /web -name 'cacert*' -exec chmod 0644 \{\} \;

