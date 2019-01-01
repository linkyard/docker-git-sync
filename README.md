# docker-git-sync

A docker container that pulls a git repository, either continuously or just once.

The docker container pulls the git repository to the directory `/data`, you need to
mount this as a volume through docker or an orchestrator like kubernetes.

If you want to execute arbitrary commands when changes to the git repository are
detected, place shell-scripts into the folder `/update-hooks` by mounting a volume
with those scripts into the container.

## Configuration

This docker container is configured through environment variables:

- `PKEY` (optional): Path to an SSH private key used for authentication
- `REPO` (required): URL of the git repository to clone
- `ONESHOT` (optional): If this is set to `true`, clone the repository once and exit
- `SKIP_CLONE` (optional): If this is set to `true`, `git clone` is skipped, assuming that the
  directory `/data` already contains the cloned git repository; the directory is only checked
  for updates with `git fetch` and `git pull`
- `BRANCH` (optional): The branch to clone; defaults to `master`
- `INTERVAL` (optional): Interval in second to check for changes. Defaults to `60`.

## Examples

To pull a repository `git@github.com:linkyard/docker-git-sync.git` once with a private key
that is stored locally in the file `/path/to/private-key/id_rsa` and pull the repository
to a folder `/path/to/data`:

```bash
docker run \
  --rm \
  -e PKEY=/var/run/private-key/id_rsa \
  -v /path/to/private-key/:/var/run/private-key/:ro \
  -e REPO=git@github.com:linkyard/docker-git-sync.git \
  -e ONESHOT=true \
  -v /path/to/data:/data \
  linkyard/git-sync
```

To check for changes every two minutes and use the `mybranch` branch:

```bash
docker run \
  --rm \
  -e PKEY=/var/run/private-key/id_rsa \
  -v /path/to/private-key/:/var/run/private-key/:ro \
  -e REPO=git@github.com:linkyard/docker-git-sync.git \
  -e INTERVAL=120 \
  -e BRANCH=mybranch \
  -v /path/to/data:/data \
  linkyard/git-sync
```

If you just want the container to do nothing, you can start the `/opt/bin/wait.sh` script
which sleeps forever. This may be useful if you want to execute the git synchronization with
`docker exec` or `kubectl exec` and don't want to allocate a tty.

```bash
docker run \
  --rm \
  -e PKEY=/var/run/private-key/id_rsa \
  -v /path/to/private-key/:/var/run/private-key/:ro \
  -e REPO=git@github.com:linkyard/docker-git-sync.git \
  -e INTERVAL=120 \
  -e BRANCH=mybranch \
  -v /path/to/data:/data \
  linkyard/git-sync \
  /opt/bin/wait.sh
```