FROM bitnami/spark:3.1.1

USER root

#RUN apt update && apt install -y wget
#RUN wget http://archive.apache.org/dist/db/derby/db-derby-10.12.1.1/db-derby-10.12.1.1-bin.tar.gz
#RUN tar -zxvf db-derby-10.12.1.1-bin.tar.gz
#RUN cp db-derby-10.12.1.1-bin/lib/derbyclient.jar /opt/bitnami/spark/jars

ENV DERBY_HOME=/opt/bitnami/spark/db-derby-10.12.1.1-bin
ENV PATH=$DERBY_HOME/bin:$PATH

RUN mkdir /opt/bitnami/spark/dwh
RUN chmod 777 /opt/bitnami/spark/dwh

USER bitnami
COPY hive-site.xml /opt/bitnami/spark/conf/
COPY job.py /opt/bitnami/spark/

