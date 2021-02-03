FROM ubuntu:focal
MAINTAINER Alessandro Pasotti<elpaso@itopen.it>

ENV DEBIAN_FRONTEND noninteractive

RUN chmod 777 /tmp && apt-get -y update && apt-get install --force-yes -y wget ca-certificates dirmngr gnupg

# Add repository for QGIS
RUN wget -qO - https://qgis.org/downloads/qgis-2020.gpg.key | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import && \
    chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg

ADD qgis-ubuntu.list /etc/apt/sources.list.d/qgis-ubuntu.list

# Install required dependencies and QGIS itself
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install --no-install-recommends --force-yes -y \
    vim \
    qgis-server \
    python3-qgis \
    apache2 \
    libapache2-mod-fcgid \
    xvfb


# Default web configuration FastCGI and htdocs
ADD default.conf /etc/apache2/sites-enabled/000-default.conf

# Enable all required apache modules
RUN a2enmod rewrite && a2enmod fcgid && a2enmod headers

# Add start script
ADD start_apache.sh /usr/local/bin/start_apache.sh
RUN chmod +x /usr/local/bin/start_apache.sh

# Add test project
COPY qgis_projects /qgis_projects

# Clean
RUN apt-get -y clean && rm -rf /var/lib/apt/lists/*

# Start
CMD /usr/local/bin/start_apache.sh
