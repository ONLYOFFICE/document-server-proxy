#!/bin/bash

path=${path:-"./nginx/proxy-to-virtual-path"}
url=${url:-"http://localhost/documentserver-virtual-path"}

# Swich to test folder
cd ${path}

# Run test environment
docker-compose up -d

# Wait for documentserver start up
sleep 15s

# Get documentserver healthcheck status
healthcheck_res=$(wget -qO - ${url}/healthcheck)

# Fail if it isn't true
if [ "${healthcheck_res}" == "true" ]; then
  echo "Healthcheck passed."
else
  echo "Healthcheck failed!"
  exit 1
fi

# Get documentserver baseurl
baseurl_res=$(wget -qO - ${url}/baseurl)

# Fail if it isn't same with url
if [ "${baseurl_res}" == "${url}" ]; then
  echo "Proxying passed."
else
  echo "Proxying failed!"
  exit 1
fi

docker-compose down
