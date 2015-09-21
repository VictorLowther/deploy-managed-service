FROM digitalrebar/base
MAINTAINER Victor Lowther <victor@rackn.com>

COPY entrypoint.d/*.sh /usr/local/entrypoint.d/

RUN  /usr/local/go/bin/go get -u github.com/digitalrebar/rebar-api/rebar && \
     cp -r $GOPATH/bin/rebar /usr/local/bin && \
     apt-get -y update && \
     apt-get -y install jq openssh-server make build-essential