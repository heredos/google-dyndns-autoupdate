#curl ifconfig.me to get the current IP address, print an error message and quit if we get an error
USERAGENT="dyndns_update.sh/1.0"
HOSTNAMES=("domainName.tld" "subdomain.domainname.tld")
USERNAMES=("username1" "username2")
PASSWORDS=("password1" "password2")

echo "---begin update $(date)---"
            
IP=$(curl -s ifconfig.me)
if [ $? -ne 0 ]; then
    echo "Error: Could not get IP address from ifconfig.me"
    exit 1
fi

#compare with thelatest known ip from the currentIp file and quit if they are the same
if [ -f currentIp ]; then
    if [ $IP == $(cat currentIp) ]; then
	echo "IP address has not changed"
	exit 0
    fi
fi

#update the currentIp file with the new IP address
echo $IP > currentIp

#loop through the hostnames and update them
for i in "${!HOSTNAMES[@]}"; do
    HOSTNAME=${HOSTNAMES[$i]}
    USERNAME=${USERNAMES[$i]}
    PASSWORD=${PASSWORDS[$i]}
    echo "Updating $HOSTNAME"
    RESPONSE=$(curl -s -A "$USERAGENT" -u "$USERNAME:$PASSWORD" "https://domains.google.com/nic/update?hostname=$HOSTNAME&myip=$IP")
    
    #print the response from google and xhzck if it went fine, orint the error in red if it didn't
    if [[ $RESPONSE == "good $IP"  ||  $RESPONSE == "nochg $IP" ]]; then
	echo -e "\e[32m$RESPONSE\e[0m"
    else
	echo -e "\e[31m$RESPONSE\e[0m"
    fi
done
echo "Done"
#curl -s -A "$USERAGENT" "https://www.duckdns.org/update?domains=$HOSTNAME&token=$USERNAME&ip=$IP"
