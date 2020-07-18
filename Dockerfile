####################
# Builder container#
####################

FROM ubuntu:16.04 as builder

MAINTAINER Chung Tran <chung.k.tran@gmail.com>

ARG ES_VERSION=6.0.0

WORKDIR /tmp/es

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y zip unzip curl wget openjdk-8-jdk && \
    wget -q https://github.com/elastic/elasticsearch/archive/v${ES_VERSION}.zip && \
    unzip -q v${ES_VERSION}.zip && \
    cd elasticsearch-${ES_VERSION}/
RUN export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 && \
    curl -s "https://get.sdkman.io" | bash && \
    source "$HOME/.sdkman/bin/sdkman-init.sh" && \
    sdk install gradle 3.3 && \
    cd elasticsearch-${ES_VERSION}/ && \
    gradle assemble
RUN cp distribution/deb/build/distributions/elasticsearch-${ES_VERSION}-SNAPSHOT.deb /var/cache/elasticsearch.deb


#################
# Main container# 
#################

FROM ubuntu:16.04

MAINTAINER Chung Tran <chung.k.tran@gmail.com>

COPY --from=builder /var/cache/elasticsearch.deb /var/cache/elasticsearch.deb

RUN dpkg -i /var/cache/elasticsearch.deb && \
    ls -l /usr/share/elasticsearch/bin

CMD ["bash"]

