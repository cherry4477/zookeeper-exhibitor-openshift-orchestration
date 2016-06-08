FROM netflixoss/java:7

ENV ZK_VERSION 3.4.8

RUN apt-get update &&\
  apt-get -y install ca-certificates &&\
  wget -q http://archive.apache.org/dist/zookeeper/zookeeper-${ZK_VERSION}/zookeeper-${ZK_VERSION}.tar.gz.md5 &&\
  wget -q http://archive.apache.org/dist/zookeeper/zookeeper-${ZK_VERSION}/zookeeper-${ZK_VERSION}.tar.gz &&\
  md5sum -c zookeeper-${ZK_VERSION}.tar.gz.md5 &&\
  tar xzf zookeeper-${ZK_VERSION}.tar.gz &&\
  rm /zookeeper-${ZK_VERSION}.tar.gz* &&\
  mv /zookeeper-${ZK_VERSION} /zookeeper
  
RUN apt-get -y install maven &&\
  mkdir /exhibitor &&\
  cd /exhibitor

COPY pom.xml /exhibitor/pom.xml
  
#RUN cd /exhibitor &&\
#  mvn assembly:single &&\
#  mv target/exhibitor-1.0-jar-with-dependencies.jar . &&\
#  rm -rf /exhibitor/target &&\
#  rm /exhibitor/pom.xml
  
RUN cd /exhibitor &&\
  mvn clean package &&\
  mv /exhibitor/target/exhibitor-1.5.6.jar . &&\
  rm -rf /exhibitor/target &&\
  rm /exhibitor/pom.xml
  
COPY exhibitor.properties /exhibitor/exhibitor.properties
COPY log4j.properties /zookeeper/conf/log4j.properties
COPY entrypoint.sh /

WORKDIR /exhibitor

ENV PATH=${JAVA_HOME}/bin:/zookeeper/bin:${PATH} \
    ZOO_LOG_DIR=/zookeeper/log \
    ZOO_LOG4J_PROP="INFO, CONSOLE, ROLLINGFILE" \
    JMXPORT=9010

EXPOSE 2181 2888 3888 8080

ENTRYPOINT [ "/entrypoint.sh" ]

# CMD [ "zkServer.sh", "start-foreground" ]

# CMD ["java", "-jar", "exhibitor-1.0-jar-with-dependencies.jar", "-c", "file"]

CMD ["java", "-jar", "exhibitor-1.5.6.jar", "-c", "file"]

