#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 [Tab URL Prefix] [cURL command ...]"
    exit 1
fi

DEBUG_URL=$(curl "http://127.0.0.1:9222/json" -s | jq -r ".[] | select(.url | startswith(\"$1\")) | .webSocketDebuggerUrl")
if ! [[ "$DEBUG_URL" =~ ^ws.* ]]; then
    echo "Could not find tab starting with '$1'. Is chrome running ?"
    exit 1
fi

URL_COUNT=$(echo "$DEBUG_URL" | tr -cd '\n' | wc -c)
if [[ "$URL_COUNT" -gt 1 ]]; then
    echo "Pattern '$1' is not precise enough. Multiple tabs/workers where found"
    exit 1
fi

COOKIES=$(echo '{ "id":2, "method":"Network.getCookies", "params":{} }' | websocat -t - $DEBUG_URL | jq -r '.result.cookies[] | "\(.name)=\(.value)"' | tr '\n' ';' | sed 's/\;$/\n/')
curl -H "Cookie: $COOKIES" "${@:2}"
