FROM ubuntu:latest
RUN  apt-get update \
     && apt-get install -y ca-certificates-java zlib1g openjdk-8-jdk openjdk-17-jdk gh bash curl

COPY action.sh /action.sh
ENTRYPOINT ["/action.sh"]
