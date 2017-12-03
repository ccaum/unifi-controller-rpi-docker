# Build Docker image to run the UniFi controller
#
FROM jsurf/rpi-raspbian:latest
MAINTAINER Carl Caum carl@carlcaum.com

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV UNIFI_VERSION 5.6.22

# Add apt repository keys, non-default sources, update apt database to load new data
# Install deps and mongodb, download unifi .deb, install and remove package
# Cleanup after apt to minimize image size
RUN echo 'deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti' | tee -a /etc/apt/sources.list.d/ubnt.list > /dev/null && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50 && \
  apt-get update -q && \
  #apt-get --no-install-recommends -y install \
  #  supervisor \
  #  binutils \
  apt-get -y install openjdk-8-jre-headless && \
  apt-get install unifi -y && \
  echo 'JAVA_HOME=/usr/lib/jvm/java-8-openjdk-armhf/' | sudo tee /etc/default/unifi > /dev/null && \
  echo 'ENABLE_MONGODB=no' | sudo tee -a /etc/mongodb.conf > /dev/null && \
  # wget -nv https://www.ubnt.com/downloads/unifi/$UNIFI_VERSION/unifi_sysvinit_all.deb && \
  # dpkg --install unifi_sysvinit_all.deb && \
  # fix WebRTC stack guard error
  # rm unifi_sysvinit_all.deb && \
  # apt-get -y autoremove wget prelink && \
  apt-get -q clean && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /tmp/* /var/tmp/*

RUN echo 'JVM_EXTRA_OPTS=-nodetach ' | tee -a /etc/default/unifi > /dev/null

# Forward apporpriate ports
EXPOSE 3478/udp 6789/tcp 8080/tcp 8443/tcp 8843/tcp 8880/tcp 10001/udp

# Set internal storage volume
VOLUME ["/usr/lib/unifi/data", "/usr/lib/unifi/logs"]

# Set working directory for program
WORKDIR /usr/lib/unifi

ENTRYPOINT /usr/lib/unifi/bin/unifi.init start
