#!/usr/bin/env bash

#URL="192.168.99.100:9200"
URL="localhost:8010/api/v2/builders"
EXITCODE=1
MAXRETR=60
i="0"

echo "Waiting for CICD Master ..."
while [ $i -lt $MAXRETR ]; do
    STATUSCODE=$(curl -sL -w "%{http_code}\\n" $URL -o /dev/null)
    if test $STATUSCODE -ne 200; then
        echo "... $STATUSCODE wait for CICD Master ... $i"
        i=$[$i+1]
        sleep 0.5
    else
        echo "... $STATUSCODE CICD Master up and running"
        exit 0
    fi
done

echo "... fail - exceed max number of retries: $MAXRETR"
exit 1