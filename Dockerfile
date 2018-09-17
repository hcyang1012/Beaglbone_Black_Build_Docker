FROM ubuntu:latest
MAINTAINER Heecheol Yang <heecheol.yang@outlook.com>

RUN apt-get update
RUN apt-get -qq -y install git curl build-essential vim
