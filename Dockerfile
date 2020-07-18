#####################
# Builder container #
#####################

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
RUN cp elasticsearch-${ES_VERSION}/distribution/deb/build/distributions/elasticsearch-${ES_VERSION}-SNAPSHOT.deb /var/cache/elasticsearch.deb


##################
# Main container #
##################

FROM ubuntu:16.04

MAINTAINER Chung Tran <chung.k.tran@gmail.com>

COPY --from=builder /var/cache/elasticsearch.deb /var/cache/elasticsearch.deb

RUN apt-get update && apt-get install -y openjdk-8-jdk && \
    dpkg -i /var/cache/elasticsearch.deb && \
    apt-get clean
RUN sysctl -w vm.max_map_count=262144

ENV ES_CONFIG /etc/elasticsearch/elasticsearch.yml
RUN echo 'network.host: 0.0.0.0' >> $ES_CONFIG && \
    echo 'discovery.type: single-node' >> $ES_CONFIG

EXPOSE 9200 9300

USER elasticsearch

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

CMD ["/usr/share/elasticsearch/bin/elasticsearch"]

