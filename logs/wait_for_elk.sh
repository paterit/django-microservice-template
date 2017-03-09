#!/usr/bin/env bash

#URL="192.168.99.100:9200"
URL="localhost:5601"
EXITCODE=1
MAXRETR=30
i="0"

echo "Waiting for ELK ..."
while [ $i -lt $MAXRETR ]; do
    STATUSCODE=$(curl -sL -w "%{http_code}\\n" $URL -o /dev/null)
    if test $STATUSCODE -ne 200; then
        echo "... $STATUSCODE wait for ELK ... $i"
        i=$[$i+1]
        sleep 0.5
    else
        echo "... ELK up and running"
        exit 0
    fi
done

echo "... fail - exceed max number of retries: $MAXRETR"
exit 1