#!/bin/bash

onSigTerm() {
    # wake from sleep and terminate
    touch /tmp/.stop-sleeping
    # shellcheck disable=2009
    ps xuaf | grep sleep | grep -v grep | awk '{print $1}' | xargs -r kill
}
trap onSigTerm HUP INT QUIT TERM

while (true); do
  if [ -e /tmp/.stop-sleeping ]; then
    echo "Exiting."
    exit 0
  fi

  sleep 60;
done
