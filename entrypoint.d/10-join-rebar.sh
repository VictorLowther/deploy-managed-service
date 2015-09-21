#!/bin/bash

# does the rebar-joined-role exist?
if ! rebar nodes roles $HOSTNAME  |grep -q 'rebar-joined-node'; then
    rebar nodes bind "$HOSTNAME" to 'rebar-joined-node'
    if [ "$THE_LOCAL_NETWORK" != "" ] ; then
        rebar nodes bind "$HOSTNAME" to "network-${THE_LOCAL_NETWORK}"
    fi
fi
