FROM ubuntu:20.04
MAINTAINER IriKa

ARG GERRIT_VERSION=3.3.3-1  \
    GERRIT_URL=http://bionic.gerritforge.com/dists/gerrit/contrib/binary-amd64

ADD entrypoint.sh /

# Install OpenJDK and Gerrit in two subsequent transactions
# (pre-trans Gerrit script needs to have access to the Java command)
RUN apt-get update &&                                                                   \
    apt-get -y install sudo openjdk-11-jdk curl &&                                      \
    curl -o/tmp/gerrit.deb "${GERRIT_URL}/gerrit-${GERRIT_VERSION}.noarch.deb" &&       \
    (dpkg -i /tmp/gerrit.deb || apt-get install -fy) && apt-mark hold gerrit &&         \
    /entrypoint.sh init &&                                                              \
    bash -c 'rm -Rf /var/gerrit/etc/{ssh,secure}*                                       \
                    /var/gerrit/{static,index,logs,data,index,cache,git,db,tmp}/*' &&   \
    chown -R gerrit:gerrit /var/gerrit &&                                               \
    apt-get -y purge curl && apt-get -y autopurge && apt-get -y clean &&                \
    bash -c 'rm -Rf {/var,}/tmp/* {/var,}/tmp/.[!.]*                                    \
                    /var/lib/apt/{lists,mirrors}/*'

USER gerrit

ENV CANONICAL_WEB_URL=
ENV HTTPD_LISTEN_URL=

# Allow incoming traffic
EXPOSE 29418 8080

VOLUME ["/var/gerrit/git", "/var/gerrit/index", "/var/gerrit/cache", "/var/gerrit/db", "/var/gerrit/etc"]

ENTRYPOINT ["/entrypoint.sh"]
