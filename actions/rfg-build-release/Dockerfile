FROM alpine/git
RUN apk add --no-cache java-cacerts zlib openjdk8 openjdk17 github-cli bash curl \
#    && apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/ perl-file-rename \
    && rm -rf /var/cache/apk/*

COPY action.sh /action.sh
ENTRYPOINT ["/action.sh"]
