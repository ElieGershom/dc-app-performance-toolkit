# name: atlassian/dcapt
# working dir: dc-app-performance-toolkit
# build: docker build -t atlassian/dcapt .
# bzt run: docker run --shm-size=4g -v "$PWD:/dc-app-performance-toolkit" atlassian/dcapt jira.yml
# interactive run: docker run -it --entrypoint="/bin/bash" -v "$PWD:/dc-app-performance-toolkit" atlassian/dcapt

FROM blazemeter/taurus

ENV APT_INSTALL="apt-get -y install --no-install-recommends"

# Temp solution for the https://github.com/nodesource/distributions/issues/1266
RUN curl -s http://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN sh -c "echo deb http://deb.nodesource.com/node_14.x focal main > /etc/apt/sources.list.d/nodesource.list"
RUN apt-get update
RUN apt-get install nodejs



RUN apt-get -y update \
  && $APT_INSTALL ca-certificates vim git openssh-server python3.8-dev python3-pip wget \
  && update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1 \
  && python -m pip install --upgrade pip \
  && python -m pip install --upgrade setuptools \
  && apt-get clean

RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  && $APT_INSTALL ./google-chrome-stable_current_amd64.deb \
  && rm -rf ./google-chrome-stable_current_amd64.deb

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

RUN rm -rf /root/.bzt/jmeter-taurus/

WORKDIR /dc-app-performance-toolkit/app

ENTRYPOINT ["bzt", "-o", "modules.console.disable=true"]
