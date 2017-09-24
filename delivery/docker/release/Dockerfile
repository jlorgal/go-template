FROM alpine:3.6
LABEL maintainer Jorge Lorenzo <jlorgal@gmail.com>

RUN apk update

WORKDIR /opt/demo

COPY delivery/docker/release/entrypoint.sh /opt/demo/
COPY bin/ /opt/demo/

ENTRYPOINT ["entrypoint.sh"]
