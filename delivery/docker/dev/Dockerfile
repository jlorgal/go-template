FROM alpine:3.6
LABEL maintainer Jorge Lorenzo <jlorgal@gmail.com>

# Install packages for golang environment
RUN apk update && \
    apk add git gcc make libc-dev go

# Install golang packages
RUN go get -u github.com/golang/lint/golint && \
    go get -u github.com/golang/dep/cmd/dep

# Set Go project
ARG PROJECT=github.com/jlorgal/go-template
ENV GOPROJECT=/root/go/src/${PROJECT}

# Mount the source code of the project under GOPATH
VOLUME ${GOPROJECT}
WORKDIR ${GOPROJECT}
