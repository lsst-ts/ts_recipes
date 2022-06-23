FROM almalinux:8

ARG PYTHON_VERSION=3.8

ENV OSPL_HOME=/opt/OpenSpliceDDS/V6.9.0/HDE/x86_64.linux

USER root

RUN dnf install -y mlocate
RUN dnf install -y epel-release
RUN adduser -u 1004 -m -s /bin/bash saluser
RUN dnf install -y iproute gcc-c++ make ncurses-libs xterm xorg-x11-fonts-misc java-1.8.0-openjdk-devel maven python3-devel swig git tk-devel wget bzip2

COPY lsst-ts-nexus.repo /tmp/lsst-ts-nexus.repo

RUN cat /tmp/lsst-ts-nexus.repo >> /etc/dnf/dnf.conf && dnf install -y OpenSpliceDDS-6.9.0
USER saluser
WORKDIR /home/saluser

RUN wget --no-verbose https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && chmod +x miniconda.sh && ./miniconda.sh -b

RUN source ~/miniconda3/bin/activate && \
    conda config --add channels conda-forge && \
    conda config --add channels lsstts && \
    conda install -y python=$PYTHON_VERSION conda-build anaconda-client

COPY setup.sh /home/saluser/.setup.sh

ENTRYPOINT ["/bin/bash", "--"]
CMD ["/home/saluser/.setup.sh"]
