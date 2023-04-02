#!/bin/bash

# Check if at least two arguments were provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 [Tab URL Prefix] [cURL command ...]"
    exit 1
fi

# Use cURL to get the JSON information on the openTab using your local Chrome instance's debug feature
DEBUG_URL=$(curl "http://127.0.0.1:9222/json" -s | jq -r ".[] | select(.url | startswith(\"$1\")) | .webSocketDebuggerUrl")

# If debug URL cannot be found, prompt the user and exit
if ! [[ "$DEBUG_URL" =~ ^ws.* ]]; then
    echo "Could not find tab starting with '$1'. Is chrome running ?"
    exit 1
fi

# Count the number of URLs with that pattern
URL_COUNT=$(echo "$DEBUG_URL" | tr -cd '\n' | wc -c)

# If there is more than one URL with the specified pattern, prompt the user and exit
if [[ "$URL_COUNT" -gt 1 ]]; then
    echo "Pattern '$1' is not precise enough. Multiple tabs/workers where found"
    exit 1
fi

# Use websocat to access the Chrome debug port and retrieve the cookies information
COOKIES=$(echo '{ "id":2, "method":"Network.getCookies", "params":{} }' | websocat -t - $DEBUG_URL | jq -r '.result.cookies[] | "\(.name)=\(.value)"' | tr '\n' ';' | sed 's/\;$/\n/')

# Append the cookies to the specified URL using curl
curl -H "Cookie: $COOKIES" "${@:2}"
