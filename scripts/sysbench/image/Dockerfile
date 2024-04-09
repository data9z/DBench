FROM centos:centos7

ADD authorized_keys /root/.ssh/authorized_keys

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && yum install -y libzstd-devel && yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm && yum install -y postgresql15 \
    && curl -sSLO https://mirrors.aliyun.com/mysql/MySQL-8.0/mysql-community-common-8.0.28-1.el7.x86_64.rpm \
    && curl -sSLO https://mirrors.aliyun.com/mysql/MySQL-8.0/mysql-community-client-plugins-8.0.28-1.el7.x86_64.rpm \
    && curl -sSLO https://mirrors.aliyun.com/mysql/MySQL-8.0/mysql-community-libs-8.0.28-1.el7.x86_64.rpm \
    && curl -sSLO https://mirrors.aliyun.com/mysql/MySQL-8.0//mysql-community-client-8.0.28-1.el7.x86_64.rpm \
    && curl -sSLO https://mirrors.aliyun.com/mysql/MySQL-8.0/mysql-community-libs-compat-8.0.28-1.el7.x86_64.rpm \
    && yum install -y *.rpm && rm -rf *.rpm \
    && curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | bash && yum -y install sysbench openssh-server \
    && yum clean all \
    && ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' \
    && ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N '' \
    && sed 's/^#Port/Port/' /etc/ssh/sshd_config \
    && sed 's/^#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config \
    && sed 's/^#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config \
    && chmod 600 /root/.ssh/authorized_keys && chmod 700 /root/.ssh