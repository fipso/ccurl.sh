#!/bin/bash

DEBUG_URL=$(curl "http://localhost:9222/json" -s | jq -r ".[] | select(.url | startswith(\"$1\")) | .webSocketDebuggerUrl")
COOKIES=$(echo '{ "id":2, "method":"Network.getCookies", "params":{} }' | websocat -t - $DEBUG_URL | jq -r '.result.cookies[] | "\(.name)=\(.value)"' | tr '\n' ';' | sed 's/\;$/\n/')

curl -H "Cookie: $COOKIES" "${@:2}"
