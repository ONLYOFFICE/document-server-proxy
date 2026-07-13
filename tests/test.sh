#!/bin/bash

path=${path:-""}
url=${url:-"http://localhost"}
expected_baseurl=${expected_baseurl:-${url}}

# SSL specific options
ssl=${ssl:-false}
config=${config:-""}
traefik_host=${traefik_host:-""}
check_websocket_headers=${check_websocket_headers:-false}

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
if [ ! -d "${path}" ]; then
  echo "File ${path} doesn't exist!"
  exit 1
fi

# Check if the docker-compose.yml exists
if [ ! -f "${path}/docker-compose.yaml" ]; then
  echo "File ${path}/docker-compose.yaml doesn't exist!"
  exit 1
fi

# Swich to test folder
cd "${path}"

compose() {
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    docker compose "$@"
  fi
}

cleanup() {
  status=$?

  compose -p ds down || true

  if [ -n "${config_backup}" ] && [ -f "${config_backup}" ]; then
    cp "${config_backup}" "${config}"
    rm -f "${config_backup}"
  fi

  exit ${status}
}

trap cleanup EXIT

if [ -n "${config}" ]; then

  # Check if the config exists
  if [ ! -f "${config}" ]; then
    echo "File ${config} doesn't exist!"
    exit 1
  fi

  config_backup=$(mktemp)
  cp "${config}" "${config_backup}"
fi

# Check if the ssl enabled
if [ "${ssl}" == "true" ]; then

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

if [ -n "${traefik_host}" ] && [ -n "${config}" ]; then
  sed 's,{{TRAEFIK_HOST}},'"${traefik_host}"',' -i ${config}
fi

if [ "${check_websocket_headers}" == "true" ] && [ -n "${config}" ] && grep -q "proxy_set_header" "${config}"; then
  if ! grep -Eq "proxy_set_header[[:space:]]+Upgrade[[:space:]]+" "${config}"; then
    echo "Missing Upgrade proxy header in ${config}."
    exit 1
  fi

  if ! grep -Eq "proxy_set_header[[:space:]]+Connection[[:space:]]+" "${config}"; then
    echo "Missing Connection proxy header in ${config}."
    exit 1
  fi

  if ! grep -Eq "proxy_set_header[[:space:]]+X-Forwarded-Proto[[:space:]]+" "${config}"; then
    echo "Missing X-Forwarded-Proto proxy header in ${config}."
    exit 1
  fi

  echo "WebSocket and forwarded proto config passed."
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
compose -p ds up -d || exit 1

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
if [ "${baseurl_res}" == "${expected_baseurl}" ]; then
  echo "Proxying passed."
else
  echo "Proxying failed! Expected '${expected_baseurl}', got '${baseurl_res}'."
  exit 1
fi

if [ "${check_websocket_headers}" == "true" ]; then
  websocket_res=$(wget \
    --no-check-certificate \
    --header="Connection: upgrade" \
    --header="Upgrade: websocket" \
    --header="Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
    --header="Sec-WebSocket-Version: 13" \
    -qO - ${url}/healthcheck)

  if [ "${websocket_res}" == "true" ]; then
    echo "WebSocket upgrade headers smoke passed."
  else
    echo "WebSocket upgrade headers smoke failed!"
    exit 1
  fi
fi
