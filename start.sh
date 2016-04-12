# Start Xvfb
/usr/bin/Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset -nolisten tcp &
# Start apache
/usr/sbin/apache2 -DFOREGROUND
