FROM bitnami/spark:3.1.1

USER root
RUN mkdir /opt/bitnami/spark/dwh
RUN chmod 777 /opt/bitnami/spark/dwh

USER bitnami
COPY hive-site.xml /opt/bitnami/spark/conf/
COPY job.py /opt/bitnami/spark/

