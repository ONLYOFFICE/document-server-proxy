#!/bin/sh
PRIVATE_KEY=server.key
CERTIFICATE_REQUEST=server.csr
CERTIFACATE=server.crt

openssl genrsa -out ${PRIVATE_KEY} 2048
openssl req -new -key ${PRIVATE_KEY} -out ${CERTIFICATE_REQUEST}
openssl x509 -req -days 365 -in ${CERTIFICATE_REQUEST} -signkey ${PRIVATE_KEY} -out ${CERTIFACATE}



