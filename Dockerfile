FROM ubuntu:trusty
MAINTAINER Alessandro Pasotti<elpaso@itopen.it>

ARG APT_CATCHER_IP=localhost

# Use apt-catcher-ng caching
# Use local cached debs from host to save your bandwidth and speed thing up.
# APT_CATCHER_IP can be changed passing an argument to the build script:
# --build-arg APT_CATCHER_IP=xxx.xxx.xxx.xxx,
# set the IP to that of your apt-cacher-ng host or comment this line out
# if you do not want to use caching
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
    qgis-server \
    apache2 \
    libapache2-mod-fcgid \
    xvfb

EXPOSE 80

# Default web configuration, enables CGI, FastCGI and htdocs
ADD default.conf /etc/apache2/sites-enabled/000-default.conf

# Volume
ADD web /web

RUN mkdir -p /web/plugins /web/projects /web/logs && chown -R www-data:www-data /web

# Creates the CGI endpoint
RUN cd /usr/lib/cgi-bin/ && ln -s qgis_mapserv.fcgi qgis_mapserv.cgi

# Enable all required apache modules
RUN a2enmod rewrite && a2enmod fcgid && a2enmod cgid

# Set Apache environment variables (can be changed on docker run with -e)
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /web/logs
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_DOCUMENTROOT /web/htdocs

# Add start script
ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
CMD /usr/local/bin/start.sh

VOLUME /web
