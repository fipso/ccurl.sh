# Use cURL with Chrome Cookies

Usage: 
- Start chrome with `google-chrome-stable --remote-debugging-port=9222`
- Make sure the tab you want to steal the cookies from is the active one
- Run the script: `./ccurl.sh <Tab URL starts with pattern> <cURL Arguments...>`
- Example: `./ccurl.sh http://localhost:3000 -H "MyHeader: 1" -H "User-Agent: test" https://example.com`
