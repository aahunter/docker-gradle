FROM openjdk:8-jre
MAINTAINER https://github.com/aahunter

ARG ARG_GRADLE_VERSION
ARG ARG_GRADLE_SHA

ENV GRADLE_VERSION $ARG_GRADLE_VERSION
ENV GRADLE_SHA $ARG_GRADLE_SHA
ENV GRADLE_HOME /usr/local/gradle
ENV PATH $PATH:$GRADLE_HOME/bin

# Note: The checksum was created after downloading the zip. Could not find checksum anywhere
#       on the gradle web site.

RUN addgroup --gid 1000 gradle \
    && adduser --disabled-password --home /data --no-create-home --system -q --uid 1000 --ingroup gradle gradle \
    && mkdir /data \
    && chown gradle:gradle /data

RUN cd /usr/local \
    && wget --quiet "https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -O gradle-bin.zip \
    && echo "${GRADLE_SHA} gradle-bin.zip" | sha256sum -c - \
    && unzip "gradle-bin.zip" \
    && ln -s "/usr/local/gradle-${GRADLE_VERSION}/bin/gradle" /usr/bin/gradle \
    && rm "gradle-bin.zip"

COPY docker-entrypoint.sh /docker-entrypoint.sh

VOLUME ["/data"]

USER gradle
WORKDIR /data
EXPOSE 2375

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["gradle", "-version"]
