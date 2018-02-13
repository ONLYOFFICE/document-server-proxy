#!/bin/sh
PRIVATE_KEY=server.key
CERTIFICATE_REQUEST=server.csr
CERTIFACATE=server.crt

APACHE_CONFIG=../../proxy-https-to-http.conf
SSL_PATH=/usr/local/apache2/conf

openssl genrsa -out ${PRIVATE_KEY} 2048
openssl req -new -key ${PRIVATE_KEY} -out ${CERTIFICATE_REQUEST}
openssl x509 -req -days 365 -in ${CERTIFICATE_REQUEST} -signkey ${PRIVATE_KEY} -out ${CERTIFACATE}

sed 's,{{SSL_CERTIFICATE_PATH}},'"${SSL_PATH}/${CERTIFACATE}"',' -i ${APACHE_CONFIG}
sed 's,{{SSL_KEY_PATH}},'"${SSL_PATH}/${PRIVATE_KEY}"',' -i ${APACHE_CONFIG}

