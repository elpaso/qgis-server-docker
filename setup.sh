#!/bin/bash
# Install pip and some python modules needed by OAuth2 auth plugin
# also install oauth2-auth-plugin wps and simple-browser
apt-get -y update
apt-get -y  --force-yes install python-pip git wget unzip
pip install paver
cd /web/plugins/


wget https://github.com/elpaso/qgis-server-simple-browser/archive/master.zip
unzip master.zip
rm master.zip
mv qgis-server-simple-browser-master serversimplebrowser


# Fix permissions on certificates
find /web -name 'cacert*' -exec chmod 0644 \{\} \;

# Fix for https://github.com/qgis/QGIS/commit/1ce35cdddd785ff14b661c970ee61c879cb209f0#diff-35a2813cb6422272e9f726bb0f75ace9
sed -i -e 's/grass7Name/grassName/' /usr/share/qgis/python/plugins/processing/algs/grass/GrassAlgorithm.py


# OAuth  plugin
pip install oauthlib
