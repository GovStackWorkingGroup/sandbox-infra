#!/bin/bash

url="$1"
echo ''
echo 'Fetching top Intermediate CA for '$url

append="/.well-known/openid-configuration"
url+="$append"
jwks_uri=$(curl -s $url |jq -r '.jwks_uri')
domain=$(echo $jwks_uri |sed 's/https:\/\///' |sed 's/\/.*//')

echo ''
echo 'Domain for cert is "'$domain'"'

filename="$domain".crt

#fetch the certificates and extract only the last one on the chain with SED AND AWK MAGIC and save it to .crt file
openssl s_client -servername "$domain" -showcerts -connect "$domain":443 </dev/null 2>/dev/null |sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'| awk -v RS='(^|\n)-----BEGIN CERTIFICATE-----\n' 'END{print "-----BEGIN CERTIFICATE-----";  printf "%s" , $0}' > "$filename"

echo ''
echo '' 
echo 'Top Intermediate CA for '$domain
cat "$filename"
echo ''
echo 'Saved to: ' $filename

#get the thumprint and strip it to correct format for aws oidc 
thumb=$(openssl x509 -in "$filename" -fingerprint -sha1 -noout | sed 's/://g' |sed 's/.*=//')

echo '' 
echo 'SSL Thumbprint: "'$thumb'"'
echo '' 