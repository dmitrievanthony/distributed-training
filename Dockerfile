# Use tensorflow as base image.
FROM tensorflow/tensorflow:1.13.0rc0-py3
# Install Java and Apache Ignite.
#ADD http://mirror.linux-ia64.org/apache//ignite/2.7.0/apache-ignite-2.7.0-bin.zip apache-ignite-2.7.0-SNAPSHOT-bin.zip
#RUN apt-get update && apt-get install -y openjdk-8-jre unzip && unzip apache-ignite-2.7.0-SNAPSHOT-bin.zip && rm *.zip
ADD apache-ignite-2.7.0-SNAPSHOT-bin apache-ignite-2.7.0-SNAPSHOT-bin
RUN apt-get update && apt-get install -y openjdk-8-jre unzip
# Move ignite-tensorflow from optional into lib folder.
RUN mv apache-ignite-2.7.0-SNAPSHOT-bin/libs/optional/ignite-tensorflow apache-ignite-2.7.0-SNAPSHOT-bin/libs/ignite-tensorflow
# Install model dependencies.
ADD models/official/requirements.txt requirements.txt
RUN pip3 install --user -r requirements.txt
# Base image has wrong version of tensorflow_estimator (see https://github.com/tensorflow/tensorflow/issues/25669).
RUN pip3 install tensorflow_estimator==1.13.0rc0
# Add Apache Ignite configuration.
ADD ignite-config.xml ignite-config.xml
# Start Apache Ignite.
CMD bash apache-ignite-2.7.0-SNAPSHOT-bin/bin/ignite.sh ignite-config.xml
