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

ARG SETUPDIR=/tmp/bgc-engine-setup/
RUN mkdir -p $SETUPDIR
WORKDIR $SETUPDIR

##########################################################################################
##########################################################################################

# Prerequisites
###############
###############

RUN apt-get -y install \
curl wget git cmake \
default-jdk ant \
python3-pip python3-distutils python3-apt python-is-python3


# RUN pip install -Iv biopython==1.70

##########################################################################################
##########################################################################################

# NCBI Tools
############

RUN mkdir -p $SETUPDIR/ncbi && cd $SETUPDIR/ncbi && \
git clone https://github.com/ncbi/ncbi-vdb.git   && \
git clone https://github.com/ncbi/ngs.git        && \
git clone https://github.com/ncbi/ngs-tools.git  && \
git clone https://github.com/ncbi/sra-tools.git  && \
cd $SETUPDIR/ncbi/ncbi-vdb        && ./configure && make && make install && \
cd $SETUPDIR/ncbi/ngs             && ./configure && make && make install && \
cd $SETUPDIR/ncbi/ngs/ngs-sdk     && ./configure && make && make install && \
cd $SETUPDIR/ncbi/ngs/ngs-python  && ./configure && make && make install && \
cd $SETUPDIR/ncbi/ngs/ngs-java    && ./configure && make && make install && \
cd $SETUPDIR/ncbi/ngs/ngs-bam     && ./configure && make && make install && \
cd $SETUPDIR/ncbi/sra-tools       && ./configure && make && make install && \
cd $SETUPDIR/ncbi/ngs-tools       && ./configure && make && make install

RUN cd $SETUPDIR/ncbi && \
curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/datasets' && \
chmod +x datasets && \
mv datasets /usr/local/bin/

##########################################################################################
##########################################################################################

# Sequence Processing Tools
###########################
###########################

# SeqKit
########
RUN cd $SETUPDIR/ && \
wget -t 0 https://github.com/shenwei356/seqkit/releases/download/v2.3.1/seqkit_linux_amd64.tar.gz && \
tar zxvf seqkit_linux_amd64.tar.gz && \
mv seqkit /usr/local/bin/

# fastp
#######
# RUN cd $SETUPDIR/ && \
# git clone https://github.com/OpenGene/fastp.git && \
# cd $SETUPDIR/fastp && \
# make && make install
RUN wget http://opengene.org/fastp/fastp && \
chmod a+x ./fastp && \
mv ./fastp /usr/local/bin/

##########################################################################################
##########################################################################################

# BGCs Prediction Tools
#######################
#######################

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

##########################################################################################
##########################################################################################

# Metagenomics Processing Tools
###############################
###############################

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
git clone https://github.com/DerrickWood/kraken2.git && \
cd $SETUPDIR/kraken2 && \
chmod +x install_kraken2.sh && \
./install_kraken2.sh /apps/kraken2/

##########################################################################################
##########################################################################################

# R
###

RUN apt-get update -qq && apt-get install --no-install-recommends software-properties-common dirmngr
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
RUN apt-get update && apt-get -y install --no-install-recommends r-base r-base-dev

##########################################################################################
##########################################################################################

# Versions
##########
RUN antismash --version ; \
deepbgc info ; \
gecco --version ; \
megahit --version ; \
R --version ;

##########################################################################################
##########################################################################################

RUN apt-get -y install libssl-dev libcurl4-openssl-dev libxml2-dev libfontconfig1-dev
COPY rpackages.txt $SETUPDIR/
COPY rpackages.R $SETUPDIR/
RUN cd $SETUPDIR/
RUN ./rpackages.R
