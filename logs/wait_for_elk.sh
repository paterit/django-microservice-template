#!/usr/bin/env bash

## Waiting for ELK application to be up and running

URL_KIBANA="localhost:5601"
URL_ELASTIC="localhost:9200/_count?q=containername:doesntmatter-web&pretty"
EXITCODE=1
MAXRETR=30
i="0"

echo "Waiting for ELK ..."
while [ $i -lt $MAXRETR ]; do
    STATUSCODE_KIBANA=$(curl -sL -w "%{http_code}\\n" $URL_KIBANA -o /dev/null)
    STATUSCODE_ELASTIC=$(curl -sL -w "%{http_code}\\n" $URL_ELASTIC -o /dev/null)
    if test $STATUSCODE_KIBANA -ne 200; then
        echo "... $STATUSCODE wait for KIBANA ... $i"
    fi

    if test $STATUSCODE_ELASTIC -ne 200; then
        echo "... $STATUSCODE wait for ELASTIC ... $i"        
    fi

    if test $STATUSCODE_KIBANA -eq 200; then
        if test $STATUSCODE_ELASTIC -eq 200; then
            echo "... ELK up and running"
            exit 0
        fi
    fi
    i=$[$i+1]
    sleep 0.5
done

echo "... fail - exceed max number of retries: $MAXRETR. Have you remembered to run sudo sysctl -w vm.max_map_count=262144 ?"
exit 1