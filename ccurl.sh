#!/bin/bash

set -euo pipefail

# Define constant variables
readonly JQ_CMD="jq"
readonly WEBSOCAT_CMD="websocat"
readonly TAB_URL_PREFIX="${1:?Usage: $0 [Tab URL Prefix] [cURL command ...]}"

# Check if required commands are installed
command -v "$JQ_CMD" &> /dev/null || {
    printf "%s command not found. Please install it and try again.\n" "$JQ_CMD"
    exit 1
}

command -v "$WEBSOCAT_CMD" &> /dev/null || {
    printf "%s command not found. Please install it and try again.\n" "$WEBSOCAT_CMD"
    exit 1
}

# Get the WebSocketDebuggerUrl for the tab with the specified prefix
get_debug_url() {
    local debug_url
    debug_url=$(curl "http://127.0.0.1:9222/json" -s | "$JQ_CMD" -r --arg prefix "$TAB_URL_PREFIX" '.[] | select(.url | startswith($prefix)) | .webSocketDebuggerUrl')
    if [[ -z $debug_url || $debug_url != ws* ]]; then
        printf "Could not find tab starting with '%s'. Is chrome running ?\n" "$TAB_URL_PREFIX"
        exit 1
    fi
    printf '%s\n' "$debug_url"
}

# Get the cookies for the tab with the specified WebSocketDebuggerUrl
get_cookies() {
    local cookies
    cookies=$(cat <<-EOF | "$WEBSOCAT_CMD" -t - "$1" | "$JQ_CMD" -r '.result.cookies[] | "\(.name)=\(.value | @uri)";' | tr -d '\n\r'
    { "id":2, "method":"Network.getCookies", "params":{} }
EOF
)
    printf '%s\n' "$cookies"
}

# Get the debug url for the tab
debug_url=$(get_debug_url)

# Get the cookies for the tab
cookies=$(get_cookies "$debug_url")

# Execute the cURL command with the cookies and capture the output
if ! output=$(curl -sSL -H "Cookie: $cookies" "${@:2}" 2>&1); then
    printf "cURL command failed: %s\n" "$output"
    exit 1
fi

printf '%s\n' "$output"
