#!/bin/bash

path=${path:-""}
url=${url:-"http://localhost"}

# SSL specific options
ssl=${ssl:-false}
config=${config:-""}

private_key=server.key
certificate_request=server.csr
certificate=server.crt
certificate_private_key=server.pem

ssl_path=/etc/ssl

# SSL backend specific options
ssl_backend=${ssl_backend:-false}
backend_private_key=backend.key
backend_certificate_request=backend.csr
backend_certificate=backend.crt

# Check if the test folder exists
if [ ! -d ${path} ]; then
  echo "File ${path} doesn't exist!"
  exit 1
fi

# Check if the docker-compose.yml exists
if [ ! -f ${path}/docker-compose.yaml ]; then
  echo "File ${path}/docker-compose.yaml doesn't exist!"
  exit 1
fi

# Swich to test folder
cd ${path}

# Check if the ssl enabled
if [ "${ssl}" == "true" ]; then

  # Check if the config exists
  if [ ! -f ${config} ]; then
    echo "File ${config} doesn't exist!"
    exit 1
  fi

  # Generate certificate
  openssl genrsa -out ${private_key} 2048
  openssl req \
    -new \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
    -key ${private_key} \
    -out ${certificate_request}
  openssl x509 -req -days 365 -in ${certificate_request} -signkey ${private_key} -out ${certificate}
  
  # Create combined file for haproxy 
  cat ${certificate} ${private_key} > ${certificate_private_key}

  # Change config
  sed 's,{{SSL_CERTIFICATE_PATH}},'"${ssl_path}/certs/${certificate}"',' -i ${config}
  sed 's,{{SSL_KEY_PATH}},'"${ssl_path}/private/${private_key}"',' -i ${config}
  sed 's,{{SSL_CERTIFICATE_KEY_PATH}},'"${ssl_path}/certs/${certificate_private_key}"',' -i ${config}
fi

# Check if the ssl back enabled
if [ "${ssl_backend}" == "true" ]; then

  # Generate backend certificate
  openssl genrsa -out ${backend_private_key} 2048
  openssl req \
    -new \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=backendserver-address" \
    -key ${backend_private_key} \
    -out ${backend_certificate_request}
  openssl x509 -req -days 365 -in ${backend_certificate_request} -signkey ${backend_private_key} -out ${backend_certificate}

fi

# Run test environment
docker-compose -p ds up -d

wakeup_attempts=30
wakeup_timeout=5

for ((i=0; i<${wakeup_attempts}; i++))
do
  # Get documentserver healthcheck status
  healthcheck_res=$(wget --no-check-certificate -qO - ${url}/healthcheck)
  
  if [ "${healthcheck_res}" == "true" ]; then
    break
  else
    echo "Wait for service wake up #${i}"
    sleep ${wakeup_timeout}
  fi
done

# Fail if it isn't true
if [ "${healthcheck_res}" == "true" ]; then
  echo "Healthcheck passed."
else
  echo "Healthcheck failed!"
  exit 1
fi

# Get documentserver baseurl
baseurl_res=$(wget --no-check-certificate -qO - ${url}/baseurl)

# Fail if it isn't same with url
if [ "${baseurl_res}" == "${url}" ]; then
  echo "Proxying passed."
else
  echo "Proxying failed!"
  exit 1
fi

docker-compose -p ds down
