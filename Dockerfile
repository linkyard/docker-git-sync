FROM alpine

RUN apk add --no-cache bash git tini openssh && mkdir -p /opt/bin
COPY git-ssh.sh /opt/bin/git-ssh.sh
COPY git-sync.sh /opt/bin/git-sync.sh

VOLUME ["/data", "/update-hooks" ]
CMD [ "tini", "-g", "--", "/opt/bin/git-sync.sh" ]
