FROM python:3.5-jessie
MAINTAINER Benjamin Hutchins <ben@hutchins.co>


### Setup system
ENV DEBIAN_FRONTEND noninteractive
RUN \
  echo "### Setup system packages" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
      locales \
      gettext \
      ca-certificates \
      nginx \
  && rm -rf /var/lib/apt/lists/* \
  \
  && echo "### Setup system locale" \
  && echo "LANGUAGE=en"        >  /etc/default/locale \
  && echo "LANG=en_US.UTF-8"   >> /etc/default/locale \
  && echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale \
  && echo "en_US.UTF-8 UTF-8"  >  /etc/locale.gen \
  && locale-gen \
  \
  && echo "### Setup nginx access/error log to stdout/stderr" \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log 
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8


### Copy required taiga files
COPY taiga-back /usr/src/taiga-back
COPY taiga-front-dist/ /usr/src/taiga-front-dist
COPY docker-settings.py /usr/src/taiga-back/settings/docker.py
COPY conf/nginx /etc/nginx
COPY conf/taiga /taiga
COPY checkdb.py /checkdb.py
COPY docker-entrypoint.sh /docker-entrypoint.sh


### Setup taiga
WORKDIR /usr/src/taiga-back
RUN \
  echo "### Symlink taiga configuration to config dir" \
  && ln -s /taiga/local.py /usr/src/taiga-back/settings/local.py \
  && ln -s /taiga/conf.json /usr/src/taiga-front-dist/dist/conf.json \
  \
  && echo "### Symlink taiga configuration to legacy config dir" \
  && mkdir -p /usr/src/taiga-front-dist/dist/js/ \
  && ln -s /taiga/conf.json /usr/src/taiga-front-dist/dist/js/conf.json \
  \
  && echo "### Install required python dependencies" \
  && pip install --no-cache-dir -r requirements.txt


### Taiga configuration variables
ENV TAIGA_SSL False
ENV TAIGA_ENABLE_EMAIL False
ENV TAIGA_HOSTNAME localhost
ENV TAIGA_SECRET_KEY "!!!REPLACE-ME-j1598u1J^U*(y251u98u51u5981urf98u2o5uvoiiuzhlit3)!!!"

### Container configuration
EXPOSE 80 443
VOLUME /usr/src/taiga-back/media
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
