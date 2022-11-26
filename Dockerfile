FROM ubuntu:22.04

LABEL description="BGC Docker Image"
LABEL maintainer="amoustafa@aucegypt.edu"

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

##########################################################################################
##########################################################################################

RUN apt-get update --fix-missing && \
apt-get -y upgrade && \
apt-get -y install apt-utils dialog software-properties-common
RUN add-apt-repository universe && \
add-apt-repository multiverse && \
add-apt-repository restricted

##########################################################################################
##########################################################################################

ARG SETUPDIR=/tmp/next-bgc-toolbox-setup/
RUN mkdir -p $SETUPDIR
WORKDIR $SETUPDIR

##########################################################################################
##########################################################################################

# Prerequisites
###############
###############

RUN apt-get -y install wget git \
python3-pip

##########################################################################################
##########################################################################################

# fastp
#######
# RUN cd $SETUPDIR/ && \
# git clone https://github.com/OpenGene/fastp.git && \
# cd $SETUPDIR/fastp && \
# make && make install
RUN wget http://opengene.org/fastp/fastp && \
chmod a+x ./fastp && \
mv ./fastp /usr/local/bin/


# DeepBGC
#########
RUN apt-get update && \
apt-get -y install software-properties-common && \
add-apt-repository ppa:deadsnakes/ppa && \
apt-get install -y python3-distutils python3-apt
RUN pip install kiwisolver --force
RUN pip install deepbgc
RUN pip install deepbgc[hmm]
RUN pip install -Iv biopython==1.68
RUN deepbgc download

# GECCO
#######
RUN pip install gecco-tool


##########################################################################################
##########################################################################################

# Versions
##########
RUN deepbgc info ; \
gecco --version

##########################################################################################
##########################################################################################
