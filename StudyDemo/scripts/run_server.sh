#!/bin/sh

# Assumptions:
#   You are in the study_server directory
#   Encryption is going to use the investigator cert in the StudyDemoBundle
#   You are on MacOS and installed a current openssl using brew -
#      which defines the location of openssl

# Uncomment on MacOS when you need to use brew's openssl
OPENSSL="--openssl $(brew --cellar openssl)/$(brew which openssl | awk -F ' ' '{print $2}')/bin/openssl"

echo $OPENSSL

python study_server.py -k ../StudyDemoBundle/certs/investigator/rsaprivkey.pem -i ../StudyDemoBundle/certs/investigator/rsacert.pem $OPENSSL

