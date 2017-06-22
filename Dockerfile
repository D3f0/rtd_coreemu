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
#RUN cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

RUN apt-get update && apt-get install -q -y wireshark netstat-nat && rm -rf /var/lib/apt/*
ADD etc/supervisor/conf.d/core.conf /etc/supervisor/conf.d
