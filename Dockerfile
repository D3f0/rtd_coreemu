FROM d3f0/lxdevnc

RUN apt-get update && \
    apt-get install -y \
        bridge-utils ebtables iproute2 iproute2 iproute libev4 quagga \
        libtk-img tk8.5 dirmngr net-tools tcpdump \
        net-tools quagga xorp bird isc-dhcp-server vsftpd apache2 tcpdump \
        radvd at ucarp openvpn ipsec-tools racoon traceroute mgen tshark \
        python-twisted  && \
        rm -rf /var/lib/apt/*

RUN echo "deb http://eriberto.pro.br/core/ stretch main\ndeb-src http://eriberto.pro.br/core/ stretch main" >> /etc/apt/sources.list.d/core.list && \
    apt-key adv --keyserver pgp.surfnet.nl --recv-keys 04ebe9ef && \
    apt-get -q update && apt-get -q -y install \
        core-network && \
        rm -rf /var/lib/apt/*

RUN setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap

RUN apt-get update && apt-get install -q -y wireshark netstat-nat && rm -rf /var/lib/apt/*
ADD noVNC /usr/local/noVNC
ADD websockify /usr/local/noVNC/utils/websockify
#ADD https://bootstrap.pypa.io/get-pip.py /tmp
COPY get-pip.py /tmp/
RUN python /tmp/get-pip.py && rm /tmp/get-pip.py

RUN apt-get update && apt-get install -q -y nginx && rm -rf /var/lib/apt/*
COPY etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/

EXPOSE 80

ADD etc/supervisor/conf.d/*.conf /etc/supervisor/conf.d/
