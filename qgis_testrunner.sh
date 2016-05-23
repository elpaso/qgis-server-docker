#!/bin/bash
# Run a test inside QGIS
### Turn on debug mode ###
#set -x

TEST_NAME=$1

cd /tests_directory
OUTPUT=`unbuffer qgis --optionspath /qgishome --nologo --code /usr/bin/qgis_testrunner.py $TEST_NAME  2>/dev/null`
echo $OUTPUT | grep -q FAILED
RETURN_CODE=$?
echo "$OUTPUT"
if [ $RETURN_CODE != 0 ];
    then exit 0;
fi
exit 1
