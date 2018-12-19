#!/bin/sh
if [ -z "${PKEY}" ]; then
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=quiet "$@"
else
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=quiet -i "${PKEY}" "$@"
fi
