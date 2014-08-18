#!/bin/sh

# Sends CMS to specified URL
#
# Provide filename as first argument. File to send could be (for example)
# a zip, a bz2(mime), or bz2(packed).

# Uncomment if you are using an HTTP proxy and want to observe
# PROXY=--proxy http://localhost:8888/

curl http://localhost:8080/api/upload ${PROXY} --data-binary @$1
