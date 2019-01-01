FROM alpine

RUN apk add --no-cache bash git tini openssh && mkdir -p /opt/bin
COPY git-ssh.sh /opt/bin/git-ssh.sh
COPY git-sync.sh /opt/bin/git-sync.sh
COPY wait.sh /opt/bin/wait.sh

VOLUME ["/data", "/update-hooks" ]
ENTRYPOINT [ "tini", "-g", "--" ]
CMD [ "/opt/bin/git-sync.sh" ]
