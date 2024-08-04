# Get the latest version of amazon linux (for nodejs 20.x)
FROM amazonlinux:latest

RUN yum update
RUN yum install zip tar gzip python3 -y
RUN mkdir -p /tmp/zips


COPY src/ /tmp/src
COPY script.sh /
RUN rm -rf **/node_modules

RUN chmod +x /script.sh
ENTRYPOINT ["/script.sh"]
