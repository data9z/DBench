FROM centos:centos7

ADD authorized_keys /root/.ssh/authorized_keys

RUN curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | bash && yum -y install sysbench openssh-server \
    && ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' \
    && ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N '' \
    && sed 's/^#Port/Port/' /etc/ssh/sshd_config \
    && sed 's/^#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config \
    && sed 's/^#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config \
    && chmod 600 /root/.ssh/authorized_keys && chmod 700 /root/.ssh