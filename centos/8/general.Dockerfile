FROM centos:8.2.2004
MAINTAINER IriKa

ARG GERRIT_VERSION=3.3.3-1  \
    GERRIT_URL=http://yum.gerritforge.com

ADD entrypoint.sh /

# Install OS pre-prequisites, OpenJDK and Gerrit in two subsequent transactions
# (pre-trans Gerrit script needs to have access to the Java command)
RUN yum -y install initscripts &&                                           \
    yum -y install java-11-openjdk git &&                                   \
    rpm -i "${GERRIT_URL}/gerrit-${GERRIT_VERSION}.noarch.rpm" &&           \
    /entrypoint.sh init &&                                                  \
    rm -Rf /var/gerrit/etc/{ssh,secure}*                                    \
           /var/gerrit/{static,index,logs,data,index,cache,git,db,tmp}/* && \
    chown -R gerrit:gerrit /var/gerrit &&                                   \
    yum -y clean all &&                                                     \
    rm -Rf {/var,}/tmp/* {/var,}/tmp/.[!.]*                                 \
           /var/lib/apt/{lists,mirrors}/*

# Enable LEGACY security policies by default (for TLS 1.0/1.1 compatibility)
RUN update-crypto-policies --set LEGACY

USER gerrit

ENV CANONICAL_WEB_URL=
ENV HTTPD_LISTEN_URL=

# Allow incoming traffic
EXPOSE 29418 8080

VOLUME ["/var/gerrit/git", "/var/gerrit/index", "/var/gerrit/cache", "/var/gerrit/db", "/var/gerrit/etc"]

ENTRYPOINT ["/entrypoint.sh"]
