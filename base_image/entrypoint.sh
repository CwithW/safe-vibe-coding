#!/bin/bash
set -e

# cleanup /tmp
rm -rf /tmp/*

# Proxy Docker socket so the runner user can access it without root
# Host socket is mounted at /var/run/docker-real.sock; socat proxies it to /var/run/docker.sock
if [ -S /var/run/docker-real.sock ]; then
    [ -e /var/run/docker.sock ] && rm -f /var/run/docker.sock
    socat UNIX-LISTEN:/var/run/docker.sock,fork,user=runner,group=runner,mode=0660 \
          UNIX-CONNECT:/var/run/docker-real.sock &
    # echo "Docker socket proxy started for runner"
fi

exec su runner -c "$@"
