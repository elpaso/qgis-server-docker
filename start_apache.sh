# Start Xvfb
set -e

if [ -f /tmp/.X99-lock ]; then
    rm -f /tmp/.X99-lock
fi
if [ -f /var/run/apache2.pid ]; then
    rm -f /var/run/apache2.pid
fi

/usr/bin/xvfb-run -n 99 -s "-screen 0 1024x768x24 -ac +extension GLX +render -noreset -nolisten tcp" apachectl -D FOREGROUND
