QGIS_SERVER_HOST=${HOSTNAME} \
    QGIS_SERVER_LOG_LEVEL=0 \
    QGIS_SERVER_LOG_FILE=/web/logs/qgis-oauth-001.log \
    QGIS_DEBUG=1 \
    python /web/qgis_oauth2_wrapped_server.py