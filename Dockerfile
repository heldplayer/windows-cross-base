FROM ubuntu:focal AS xwin

RUN set -eu ; \
    apt-get update ; \
    apt-get -y --no-install-recommends install curl ca-certificates ; \
    apt-get clean

RUN set -eu ; \
    curl --fail -L https://github.com/Jake-Shadle/xwin/releases/download/0.2.1/xwin-0.2.1-x86_64-unknown-linux-musl.tar.gz -o xwin.tar.gz ; \
    curl --fail -L https://github.com/Jake-Shadle/xwin/releases/download/0.2.1/xwin-0.2.1-x86_64-unknown-linux-musl.tar.gz.sha256 -o xwin.tar.gz.sha256

RUN set -eu ; \
    echo $(cat xwin.tar.gz.sha256) "*xwin.tar.gz" | sha256sum --check ; \
    tar -xzv -f xwin.tar.gz -C /usr/local/bin --strip-components=1 xwin-0.2.1-x86_64-unknown-linux-musl/xwin ; \
    xwin --accept-license --cache-dir /tmp/xwin-cache --temp --arch x86_64,aarch splat --output /xwin

FROM ubuntu:focal AS llvm

RUN set -eu ; \
    apt-get update ; \
    apt-get -y --no-install-recommends install curl ca-certificates gnupg dirmngr xz-utils ; \
    apt-get clean

RUN set -eu ; \
    curl --fail -L https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.0/clang+llvm-14.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz -o llvm.tar.xz ; \
    curl --fail -L https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.0/clang+llvm-14.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz.sig -o llvm.tar.xz.sig

ENV GPG_KEYS 09C4E7007CB2EFFB A2C794A986419D8A B4468DF4E95C63DC D23DD2C20DD88BA2 8F0871F202119294 0FC3042E345AD05D

RUN set -eu ; \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys $GPG_KEYS ; \
    gpg --batch --verify llvm.tar.xz.sig llvm.tar.xz

FROM python:3.10 AS base

COPY --from=llvm llvm.tar.xz /
RUN set -eu ; \
    tar -xf llvm.tar.xz -C /usr/local --strip-components=1

FROM python:3.10

COPY --from=base /usr/local /usr/local
COPY --from=xwin /xwin /xwin/

ARG USER_ID=1000
ARG USER_GROUP=1000

RUN pip install ninja pyyaml

RUN set -eu ; \
    groupadd -g $USER_GROUP host-user ; \
    useradd -m -s /bin/bash -g $USER_GROUP -u $USER_ID host-user ; \
    mkdir /data ; \
    chown host-user:host-user /data


USER host-user
WORKDIR /data
