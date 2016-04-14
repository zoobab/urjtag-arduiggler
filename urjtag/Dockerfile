FROM ubuntu:14.04
MAINTAINER Benjamin Henrion <zoobab@gmail.com>

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y -q
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q --force-yes build-essential

RUN useradd -d /home/urjtag -m -s /bin/bash urjtag
RUN echo "urjtag ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/urjtag
RUN chmod 0440 /etc/sudoers.d/urjtag

USER urjtag

WORKDIR /home/urjtag
RUN mkdir -pv /home/urjtag/urjtag
WORKDIR /home/urjtag/urjtag
COPY . /home/urjtag/urjtag/
RUN ./autogen.sh
# Build only the arduiggler cable, not the other cables
RUN ./configure --enable-cable="arduiggler
RUN make
RUN make install
RUN ldconfig
