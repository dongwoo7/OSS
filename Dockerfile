FROM ubuntu:14.04

MAINTAINER Harin Jeon <junharin2@gmail.com> Sukhyun Seo <seosukhyun@gmail.com>

# presettings
RUN apt-get update
RUN apt-get install -y build-essential autoconf automake libtool libcppunit-dev python-setuptools python-dev openjdk-7-jdk libevent-dev git curl vim sudo ant netcat

# add user
RUN adduser --disabled-password --gecos '' arcus
RUN adduser arcus sudo

# clone arcus
WORKDIR /home/arcus
RUN git clone https://github.com/naver/arcus.git

# build arcus
WORKDIR /home/arcus/arcus/scripts
RUN ./build.sh

# zookeeper settings
WORKDIR /home/arcus/arcus/zookeeper
RUN ant compile_jute
WORKDIR /home/arcus/arcus/zookeeper/src/c
RUN autoreconf -if
RUN ./configure --prefix=/home/arcus/arcus
RUN make && make install

# memcached & zookeeper settings
WORKDIR /home/arcus/arcus/server
RUN ./config/autorun.sh
RUN ./configure --with-libevent=/home/arcus/arcus
RUN make && make install

#ADD arcus-collectd /home/arcus/arcus-collectd
ADD clearun_arcus.sh /home/arcus/clearun_arcus.sh

# chown
ADD clearun.sh /home/arcus/arcus/scripts/clearun.sh
RUN chown -R arcus:arcus /home/arcus
USER arcus

# run arcus
WORKDIR /home/arcus/arcus/scripts


#CMD ["/bin/bash"]
EXPOSE 2181
EXPOSE 11211
EXPOSE 11212
#CMD ["/bin/bash", "/home/arcus/arcus/scripts/clearun.sh"]
CMD ["/bin/bash"]