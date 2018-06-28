#!/bin/bash

private_key=backend.key
certificate_request=backend.csr
certificate=backend.crt

# Generate certificate
openssl genrsa -out ${private_key} 2048
openssl req \
  -new \
  -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=backendserver-address" \
  -key ${private_key} \
  -out ${certificate_request}
openssl x509 -req -days 365 -in ${certificate_request} -signkey ${private_key} -out ${certificate}
