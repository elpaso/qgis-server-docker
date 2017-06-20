# Start Xvfb

set -e

if [ -f /tmp/.X99-lock ]; then
    rm -f /tmp/.X99-lock
fi
if [ -f /var/run/apache2.pid ]; then
    rm -f /var/run/apache2.pid
fi

/usr/bin/Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset -nolisten tcp &

# Start apache
/usr/sbin/apache2

# Start the python OAuth2 QGIS server
/web/run_oauth2.sh



