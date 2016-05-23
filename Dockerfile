FROM ubuntu:trusty
MAINTAINER Alessandro Pasotti<apasotti@boundlessgeo.com>


# Use apt-catcher-ng caching
# Use local cached debs from host to save your bandwidth and speed thing up.
# APT_CATCHER_IP can be changed passing an argument to the build script:
# --build-arg APT_CATCHER_IP=xxx.xxx.xxx.xxx,
# set the IP to that of your apt-cacher-ng host or comment the following 2 lines
# out if you do not want to use caching
ARG APT_CATCHER_IP=localhost
RUN  echo 'Acquire::http { Proxy "http://'${APT_CATCHER_IP}':3142"; };' >> /etc/apt/apt.conf.d/01proxy


# Add repository for QGIS
ADD debian-gis.list /etc/apt/sources.list.d/debian-gis.list
# Add the signing key
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 3FF5FFCAD71472C4

# Install required dependencies and QGIS itself
RUN apt-get -y update
RUN apt-get install -y \
    vim \
    python-qgis \
    qgis \
    xvfb \
    python-pip \
    python-dev \
    supervisor \
    expect-dev

# Add install script
ADD requirements.txt /usr/local/requirements.txt
ADD install.sh /usr/local/bin/install.sh
RUN chmod +x /usr/local/bin/install.sh
RUN /usr/local/bin/install.sh

# Add qgishome with settings for the testing script
COPY qgishome /qgishome

# Add QGIS test runner
ENV QGIS_EXTRA_OPTIONS="--optionspath /qgishome"
ADD qgis_testrunner.py /usr/bin/qgis_testrunner.py
RUN chmod +x /usr/bin/qgis_testrunner.py
ADD qgis_testrunner.sh /usr/bin/qgis_testrunner.sh
RUN chmod +x /usr/bin/qgis_testrunner.sh


# Add start script
ADD supervisord.conf /etc/supervisor/
ADD supervisor.xvfb.conf /etc/supervisor/supervisor.d/


CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
