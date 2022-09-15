FROM ubuntu:focal AS xwin

RUN set -eu ; \
    apt-get update ; \
    apt-get -y --no-install-recommends install curl ca-certificates ; \
    apt-get clean

RUN set -eu ; \
    curl --fail -L https://github.com/Jake-Shadle/xwin/releases/download/0.2.8/xwin-0.2.8-x86_64-unknown-linux-musl.tar.gz -o xwin.tar.gz ; \
    curl --fail -L https://github.com/Jake-Shadle/xwin/releases/download/0.2.8/xwin-0.2.8-x86_64-unknown-linux-musl.tar.gz.sha256 -o xwin.tar.gz.sha256

RUN set -eu ; \
    echo $(cat xwin.tar.gz.sha256) "*xwin.tar.gz" | sha256sum --check ; \
    tar -xzv -f xwin.tar.gz -C /usr/local/bin --strip-components=1 xwin-0.2.8-x86_64-unknown-linux-musl/xwin ; \
    xwin --accept-license --cache-dir /tmp/xwin-cache --temp --arch x86_64,aarch splat --output /xwin


FROM python:3.10

COPY --from=xwin /xwin /xwin/

ARG USER_ID=1000
ARG USER_GROUP=1000

RUN set -eu ; \
    apt-get update ; \
    apt-get -y --no-install-recommends install ca-certificates gnupg dirmngr xz-utils lsb-release wget software-properties-common ; \
    bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" -- 15 ; \
    apt-get clean

RUN pip install ninja pyyaml

RUN set -eu ; \
    groupadd -g $USER_GROUP host-user ; \
    useradd -m -s /bin/bash -g $USER_GROUP -u $USER_ID host-user ; \
    mkdir /data ; \
    chown host-user:host-user /data


USER host-user
WORKDIR /data
