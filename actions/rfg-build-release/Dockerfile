FROM ubuntu:latest
RUN  sudo apt-get update \
     && sudo apt-get install -y ca-certificates-java zlib1g openjdk-8-jdk openjdk-17-jdk github-cli bash curl

COPY action.sh /action.sh
ENTRYPOINT ["/action.sh"]
