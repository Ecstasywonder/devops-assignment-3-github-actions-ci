FROM alpine:3.22

LABEL org.opencontainers.image.title="DevOps Assignment 3"
LABEL org.opencontainers.image.description="Bash diagnostic CLI with CI testing"

RUN apk add --no-cache \
    bash \
    coreutils \
    util-linux \
    iputils \
    iproute2 \
    libc-utils \
    gawk

WORKDIR /opt/devops

COPY app/app.sh ./app.sh

RUN chmod +x ./app.sh

ENTRYPOINT ["/opt/devops/app.sh"]

CMD ["help"]
