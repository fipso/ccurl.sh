# Sync chrome session with curl

Tired of copy pasting cURL commands from chrome to your terminal ?  
You don't want to use GUI tools like Postman ?  
  
This short bash script uses the chrome dev tools protocol to dump cookies from a specific tab of your local chrome instance into the header of a curl command  
By doing so we also evade leaking cookies into our shell history file  
  
Usage: 
- Start chrome with `google-chrome-stable --remote-debugging-port=9222`
- Make sure the tab you want to steal the cookies from is the active one
- Run the script: `./ccurl.sh <Tab URL Prefix> <cURL command ...>`
- Example: `./ccurl.sh http://localhost:3000/ -H "User-Agent: test" http://localhost:3000/api/user`
  
Requirements:
- bash
- websocat
- jq
  
Install:  
`sudo cp ./ccurl.sh /usr/bin/ccurl && sudo chmod +x /usr/bin/ccurl`
