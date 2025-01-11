FROM lscr.io/linuxserver/calibre-web:0.6.24-ls308

COPY files/ /tmp

RUN \
  echo "**** prepare calibre empty db ****" && \
  mkdir /database && chmod 777 /database && \
  mv /tmp/metadata.db /database/metadata.db && \
  chown -R abc:abc /database

RUN \
  echo "**** move process_comics script ****" && \
  mv /tmp/process_comics.sh /process_comics.sh && \
  chmod +x /process_comics.sh
  
RUN \
  echo "**** move cron definition ****" && \
  mv /tmp/process_comics_cron /etc/cron.d/process_comics_cron && \
  crontab /etc/cron.d/process_comics_cron

RUN \
  echo "**** install kindlegen ****" && \
  tar zxvf /tmp/kindlegen*tar.gz -C /usr/bin && \
  rm -rf /tmp/kindlegen*tar.gz

ENV KCC_REPO_GIT="https://github.com/ciromattia/kcc"
ENV KCC_TAG="v7.0.0"
RUN \
  echo "**** install kcc dependencies ****" && \
  apt-get update && \
  apt-get install -y \
  python3 \
  python3-dev \
  gcc \
  unzip \
  unrar \
  p7zip-full \
  # add suport for rar from 7z - solve https://github.com/ciromattia/kcc/issues/332
  p7zip-rar \
  libpng-dev \
  libjpeg-dev \
  git \
  wget \
  libxcb-xinerama0 \
  libqt5x11extras5

RUN \
  echo "**** install yq ****" && \
  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \ 
  chmod +x /usr/bin/yq


RUN \
  echo "**** install kcc ****" && \
  pip install "git+${KCC_REPO_GIT}@${KCC_TAG}"

RUN \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*