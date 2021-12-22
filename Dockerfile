# Base image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="KAI CHU CHUNG (https://kaichu.io)"

ARG JMETER_VER=5.4.1
ARG JMETER_PLUGINS_MANAGER_VERSION=1.3
ARG CMDRUNNER_VERSION=2.2

# Set Environment varibles
ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VER}
ENV	JMETER_BIN=${JMETER_HOME}/bin
ENV JMETER_PLUGINS_DOWNLOAD_URL https://repo1.maven.org/maven2/kg/apc
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x/
ENV PATH=$JAVA_HOME/bin:$PATH

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    openjdk-11-jdk-headless \
    tar \
    wget \
    ;

# Download from git and build
RUN cd /opt \
 && wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VER.tgz \
 && tar -xvzf apache-jmeter-$JMETER_VER.tgz \
 ;

# plugins
RUN wget ${JMETER_PLUGINS_DOWNLOAD_URL}/jmeter-plugins-manager/${JMETER_PLUGINS_MANAGER_VERSION}/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar -O $JMETER_HOME/lib/ext/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar \
 && wget ${JMETER_PLUGINS_DOWNLOAD_URL}/cmdrunner/$CMDRUNNER_VERSION/cmdrunner-$CMDRUNNER_VERSION.jar -O $JMETER_HOME/lib/cmdrunner-$CMDRUNNER_VERSION.jar \
 && java -cp $JMETER_HOME/lib/ext/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar org.jmeterplugins.repository.PluginManagerCMDInstaller \
 && cd ${JMETER_HOME}/bin && ./PluginsManagerCMD.sh install jpgc-mergeresults \
 && cd ${JMETER_HOME}/bin && ./PluginsManagerCMD.sh install jpgc-synthesis \
 && cd ${JMETER_HOME}/bin && ./PluginsManagerCMD.sh install jpgc-cmd \
 && cd ${JMETER_HOME}/bin && ./PluginsManagerCMD.sh install jpgc-casutg \
 && cd ${JMETER_HOME}/bin && ./PluginsManagerCMD.sh install jpgc-json \
 && cd ${JMETER_HOME}/bin && ./PluginsManagerCMD.sh install jpgc-graphs-additional \
 && cd ${JMETER_HOME}/bin && ./PluginsManagerCMD.sh status \

#Remove G1GC algorithm as it is unimplemented in OpenJDK zero
 && sed -ie 185's/.*/# &/' $JMETER_HOME/bin/jmeter \

# Clean the Cache data and remove source files and dependencies
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 ;

# Set Environment Variable for JMeter
ENV PATH $PATH:$JMETER_BIN
ENTRYPOINT ["jmeter","-n","-t"]

# End Of Dockerfile