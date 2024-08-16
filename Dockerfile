FROM ubuntu:22.04

LABEL author="Cho Phan"

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV SPARK_HOME=/usr/local/spark

RUN \
  apt-get update \
  && apt-get install -y \
    sudo \
    openssl

RUN \
  sudo useradd -m -s /bin/bash -p $(openssl passwd -1 chophan) spark \
  && sudo usermod -aG sudo spark \
  && sudo su - spark

USER spark

RUN \
  echo "chophan" | sudo -S apt-get install -y \
    vim \
    wget \
    openjdk-8-jdk \
    ssh \
    iputils-ping \
    scala

RUN mkdir -p /home/spark/Downloads

WORKDIR /home/spark/Downloads

RUN \
  wget \
    https://archive.apache.org/dist/spark/spark-3.3.0/spark-3.3.0-bin-hadoop3-scala2.13.tgz \
    https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.1.0.tar.gz

RUN \
  tar -zxvf spark-3.3.0-bin-hadoop3-scala2.13.tgz \
  && tar -zxvf mysql-connector-j-8.1.0.tar.gz

RUN \
  echo "chophan" | sudo -S mv spark-3.3.0-bin-hadoop3-scala2.13 $SPARK_HOME \
  && sudo mv mysql-connector-j-8.1.0/mysql-connector-j-8.1.0.jar $SPARK_HOME/jars

WORKDIR $SPARK_HOME

RUN echo "chophan" | sudo -S rm -R /home/spark/Downloads

RUN \
  echo "\nexport JAVA_HOME=$JAVA_HOME" >> ~/.bashrc \
  && echo 'export PATH=$PATH:$JAVA_HOME/bin\n' >> ~/.bashrc \
  && echo "export SPARK_HOME=$SPARK_HOME" >> ~/.bashrc \
  && echo 'export PATH=$PATH:$SPARK_HOME/bin' >> ~/.bashrc

COPY /conf/spark-env.sh $SPARK_HOME/conf/
COPY /conf/etl.jar $SPARK_HOME/
COPY /start-spark.sh $SPARK_HOME/

RUN \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
  && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
  && chmod 600 ~/.ssh/authorized_keys

ENTRYPOINT ["/bin/bash", "./start-spark.sh"]
