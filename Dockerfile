# Copyright 2019 Red Hat
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ------------------------------------------------------------------------
#
# This is a Dockerfile for the spark:2.4.1 image.

# Default values of build arguments.
FROM centos:latest
ARG SPARK_VERSION="2.4.1"
ARG SPARK_DOWNLOAD_URL="https://www-us.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz"
ARG SPARK_DOWNLOAD_MD5SUM="feef63426af19b9abcfef273072b1e68"

# Default values of environment variables.
ENV \
    SPARK_HOME="/opt/spark" \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${SPARK_HOME}/bin" \
    TINI_VERSION="v0.18.0"

USER root

# Install required RPMs and ensure that the packages were installed
RUN yum install -y java-1.8.0-openjdk wget && \
    yum clean all && \
    rm -rf /var/cache/yum

# Add Tini - init for containers
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

# Download Spark and verify md5sum of file
RUN cd /opt; wget -q --progress=bar ${SPARK_DOWNLOAD_URL} -O spark-${SPARK_VERSION}-bin-hadoop2.7.tgz && \
    echo "${SPARK_DOWNLOAD_MD5SUM} spark-${SPARK_VERSION}-bin-hadoop2.7.tgz" | md5sum -c -

# Extract the Spark
RUN cd opt; tar -zxf spark-${SPARK_VERSION}-bin-hadoop2.7.tgz && \
    rm -fr spark-${SPARK_VERSION}-bin-hadoop2.7.tgz && \
    ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop2.7 /opt/spark


COPY entrypoint.sh ${SPARK_HOME}

WORKDIR ${SPARK_HOME}

ENTRYPOINT ["./entrypoint.sh"]
