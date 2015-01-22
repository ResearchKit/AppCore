#!/usr/bin/env bash

# 2048 bit keys are the minimum acceptable for handling PHI
openssl genrsa -out rsaprivkey.pem 2048
openssl rsa -in rsaprivkey.pem -pubout -outform DER -out rsapubkey.der
openssl rsa -in rsaprivkey.pem -out rsapubkey.pem -outform PEM -pubout
openssl pkcs8 -topk8 -inform PEM -outform DER -in rsaprivkey.pem -out rsaprivkey.der -nocrypt
openssl req -new -x509 -key rsaprivkey.pem -out rsacert.pem
cp rsacert.pem investigator.pem

