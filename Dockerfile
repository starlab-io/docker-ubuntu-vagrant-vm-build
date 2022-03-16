FROM ubuntu:18.04
MAINTAINER Farhan Patwa <farhan.patwa@starlab.io>

ENV DEBIAN_FRONTEND=noninteractive
ENV USER root

# build depends
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential software-properties-common ca-certificates libssl-dev \
        libvirt-dev libvirt-daemon-system automake ruby-dev ruby-libvirt \
        qemu libguestfs-tools libglib2.0-0 libglib2.0-dev libpixman-1-dev \
        python3-pip gcc pkg-config bison flex checkinstall wget jq p7zip unzip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download, build and install QEMU 4.2
RUN wget https://download.qemu.org/qemu-4.2.0.tar.xz && \
    tar xvJf qemu-4.2.0.tar.xz
WORKDIR qemu-4.2.0
RUN ./configure --target-list=x86_64-softmmu && \
    make -j$(nproc) && \
    checkinstall -y make install
WORKDIR /
RUN rm -fr qemu-4.2.0 qemu-4.2.0.tar.xz

# Download, build and install make 4.2.1
RUN wget  https://ftp.gnu.org/gnu/make/make-4.2.1.tar.gz && \
    tar -xzf make-4.2.1.tar.gz
WORKDIR make-4.2.1
RUN sed -i \
        's/_GNU_GLOB_INTERFACE_VERSION =/_GNU_GLOB_INTERFACE_VERSION >/' \
        configure.ac && \
    ./configure --prefix=/usr && \
    make -j$(nproc) && \
    make install
WORKDIR /
RUN rm -fr make-4.2.1 make-4.2.1.tar.gz

# Download and install vagrant
RUN wget  https://releases.hashicorp.com/vagrant/2.2.8/vagrant_2.2.19_x86_64.deb && \
    dpkg -i vagrant_2.2.19_x86_64.deb && \
    vagrant plugin install vagrant-libvirt && \
    rm -f vagrant_2.2.19_x86_64.deb

# Download and install packer
RUN wget https://releases.hashicorp.com/packer/1.3.4/packer_1.3.4_linux_amd64.zip && \
    unzip packer_1.3.4_linux_amd64.zip && \
    mv packer /usr/bin/ && \
    rm -f packer_1.3.4_linux_amd64.zip    
   
WORKDIR /
