#!/bin/bash

onSigTerm() {
    # wake from sleep and terminate
    touch /tmp/.stop-sleeping
    pkill sleep
}
trap onSigTerm HUP INT QUIT TERM

while (true); do
  if [ -e /tmp/.stop-sleeping ]; then
    echo "Exiting."
    exit 0
  fi

  sleep 60;
done
