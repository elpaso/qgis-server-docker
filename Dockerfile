FROM ubuntu:bionic
MAINTAINER Alessandro Pasotti<elpaso@itopen.it>

ARG APT_CATCHER_IP=localhost

RUN chmod 777 /tmp && apt-get -y update && apt-get install --force-yes -y ca-certificates dirmngr

# Add repository for QGIS
ADD debian-gis.list /etc/apt/sources.list.d/debian-gis.list
# Add the signing key
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key CAEB3DC3BDF7FB45

# Install required dependencies and QGIS itself
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install --force-yes -y \
    vim \
    qgis-server \
    python3-qgis \
    apache2 \
    libapache2-mod-fcgid \
    xvfb


# Default web configuration, enables CGI, FastCGI and htdocs
ADD default.conf /etc/apache2/sites-enabled/000-default.conf

# Enable all required apache modules
RUN a2enmod rewrite && a2enmod fcgid && a2enmod headers

ENV APACHE_DOCUMENTROOT /var/www

# Add start script
ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Clean
RUN apt-get -y clean && rm -rf /var/lib/apt/lists/*

EXPOSE 80 8082

# Start
CMD /usr/local/bin/start.sh
