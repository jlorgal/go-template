FROM alpine:3.6
LABEL maintainer Jorge Lorenzo <jlorgal@gmail.com>

# Install packages for golang environment
RUN apk update && \
    apk add --no-cache git gcc make libc-dev go cyrus-sasl-dev docker

ENV PATH=/root/go/bin:${PATH}

# Install golang packages
RUN go get -v github.com/golang/lint/golint && \
    go get -v github.com/golang/dep/cmd/dep && \
    go get -v gopkg.in/tomb.v2

# Set Go project
ARG PROJECT=github.com/jlorgal/go-template
ENV GOPROJECT=/root/go/src/${PROJECT}

# Mount the source code of the project under GOPATH
VOLUME ${GOPROJECT}
WORKDIR ${GOPROJECT}
