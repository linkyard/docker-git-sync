#!/bin/bash
if [ -z "${REPO}" ]; then
  echo "error: environment variable REPO needs to be set"
  exit 1
fi

# makes git invoke this shell-script instead of the ssh binary
# used to ignore host key checking and using the specified ssh key for pulling
export GIT_SSH="/opt/bin/git-ssh.sh"

if [ -n "${PKEY}" ]; then
  if [ ! -r "${PKEY}" ]; then
    echo "error: ${PKEY} does not exist or can't be read"
    exit 1
  else
    if [ "$(stat -c "%a" "${PKEY}")" != "600" ]; then
      echo "warning: insecure file permissions for ${PKEY}; creating a copy"
      PKEY_COPY="$(mktemp)"
      cp "${PKEY}" "${PKEY_COPY}"
      export PKEY="${PKEY_COPY}"
      chmod 600 "${PKEY}"
    fi
  fi
fi

if [ ! -d /data ]; then
  echo "error: /data is not a directory"
  exit 1
fi

cd /data || exit 1

echo "$(date +"%Y-%m-%d %H:%M:%S") cloning ${REPO}"
if ! git clone "${REPO}" .; then
  echo "error: unable to clone ${REPO}"
  exit 1
fi

BRANCH=${BRANCH:-master}
git checkout "${BRANCH}"

if [ "${ONESHOT}" = "true" ]; then
  exit 0
fi

BRANCH=${BRANCH:-master}
INTERVAL=${INTERVAL:-60}

onUpdate() {
  for updateHook in /update-hooks/*; do
    [[ -e $updateHook ]] || break;
    if [ -x "${updateHook}" ]; then
      echo "$(date +"%Y-%m-%d %H:%M:%S") executing ${updateHook}"
      "${updateHook}"
    else
      echo "$(date +"%Y-%m-%d %H:%M:%S") invoking ${updateHook} with a shell"
      sh "${updateHook}"
    fi
  done
}

while (true); do
  sleep "${INTERVAL}"
  git fetch origin
  # shellcheck disable=SC2181
  if [ $? -ne 0 ]; then
    echo "error: unable to fetch ${REPO}"
    exit 1
  fi
  if [ "$(git rev-list "HEAD..origin/${BRANCH}" --count)" -gt 0 ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") changes in ${REPO} detected"
    git pull
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
      echo "error: unable to pull ${REPO}"
      exit 1
    fi
    onUpdate
  fi
done
