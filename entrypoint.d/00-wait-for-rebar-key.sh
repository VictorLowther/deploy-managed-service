#!/bin/bash

while [[ ! -e /etc/rebar-data/rebar-key.sh ]] ; do
  echo "Waiting for rebar-key.sh to show up"
  sleep 5
done

# Wait for the webserver to be ready.
. /etc/rebar-data/rebar-key.sh
while ! rebar ping &>/dev/null; do
  sleep 1
  . /etc/rebar-data/rebar-key.sh
done

service ssh start

# This could error if this is the first time.  Ignore it
#set +e
# Node id is harcoded here, and that is a Bad Thing
mkdir -p /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
while read line; do
    fgrep -q "$line" "/root/.ssh/authorized_keys" && continue
    echo "$line" >> "/root/.ssh/authorized_keys"
done < <(rebar deployments get 1 attrib rebar-access_keys |jq -r -c '.value | .[]')

DOMAIN="$(rebar nodes get "system-phantom.internal.local" attrib dns-domain | jq -r .value)"
if [ $DOMAIN == "null" ] ; then
  echo "Domain must be set to something"
  exit 1
fi

if [[ ! $SERVICE_NAME ]]; then
    echo "Service name not set!"
    exit 1
fi

export HOSTNAME="$SERVICE_NAME.$DOMAIN"

# Add node to DigitalRebar
if ! rebar nodes show "$HOSTNAME"; then
  # Create a new node for us,
  # Let the annealer do its thing.
  rebar nodes import "{\"name\": \"$HOSTNAME\", \"admin\": true, \"ip\": \"$IP\", \"bootenv\": \"local\"}"|| {
    echo "We could not create a node for ourself!"
    #exit 1
  }
else
  echo "Node already created, moving on"
fi
