FROM ubuntu:22.04

LABEL description="BGC Engine Docker Image"
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

RUN apt-get -y install \
wget git \
python3-pip python3-distutils python3-apt

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
# RUN apt-get update && \
# apt-get -y install software-properties-common && \
# add-apt-repository ppa:deadsnakes/ppa

RUN apt-get -y install hmmer
RUN pip install kiwisolver --force
RUN pip install deepbgc
RUN pip install deepbgc[hmm]
RUN pip install -Iv biopython==1.70
# RUN deepbgc download

# GECCO
#######
RUN pip install gecco-tool

# antiSMASH
###########
RUN apt-get update && \
apt-get -y install apt-transport-https
RUN wget http://dl.secondarymetabolites.org/antismash-stretch.list -O /etc/apt/sources.list.d/antismash.list && \
wget -q -O- http://dl.secondarymetabolites.org/antismash.asc | apt-key add -
RUN apt-get update && \
apt-get -y install hmmer2 hmmer diamond-aligner fasttree prodigal ncbi-blast+ muscle glimmerhmm

RUN cd $SETUPDIR/ && \
wget https://dl.secondarymetabolites.org/releases/6.1.1/antismash-6.1.1.tar.gz && tar -zxf antismash-6.1.1.tar.gz && \
pip install ./antismash-6.1.1
# RUN download-antismash-databases

RUN apt-get -y install cmake

# MEGAHIT
#########
RUN cd $SETUPDIR/ && \
git clone https://github.com/voutcn/megahit.git && \
cd $SETUPDIR/megahit && \
git submodule update --init && \
mkdir build && \
cd $SETUPDIR/megahit/build && \
cmake .. -DCMAKE_BUILD_TYPE=Release && make -j4 && make simple_test  && make install

# Kraken2
#########
RUN mkdir -p /apps/kraken2/ && \
cd $SETUPDIR/ && \
git clone git@github.com:DerrickWood/kraken2.git && \
cd $SETUPDIR/kraken2 && \
install_kraken2.sh /apps/kraken2/

##########################################################################################
##########################################################################################

# Versions
##########
RUN megahit --version ; \
antismash --version ; \
deepbgc --versio ; \
gecco --version 

##########################################################################################
##########################################################################################
