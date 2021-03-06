FROM phusion/baseimage:0.9.11
# https://github.com/phusion/baseimage-docker
MAINTAINER Nguyen Ngoc Tu <axitdn@gmail.com>

ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]

# ==============================================================================
# install deps
# ==============================================================================
RUN apt-get update \
  && apt-get install -y ruby gems g++ ruby-dev libcurl3 libcurl3-gnutls \
  libcurl4-openssl-dev imagemagick default-jre inkscape phantomjs \
  calibre nodejs
RUN apt-get install -y texlive-full texlive-lang-vietnamese

# nodejs => node
RUN cd /usr/local/bin && ln -s /usr/bin/nodejs node

WORKDIR /root
# ==============================================================================
# install epubcheck
# ==============================================================================
RUN curl -LO \
  https://github.com/IDPF/epubcheck/releases/download/v3.0/epubcheck-3.0.zip \
  && unzip epubcheck-3.0.zip -d bin && rm epubcheck-3.0.zip

# ==============================================================================
# install kindlegen
# ==============================================================================
RUN curl -LO \
  http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz \
  && tar -zxvf kindlegen_linux_2.6_i386_v2_9.tar.gz \
  && rm kindlegen_linux_2.6_i386_v2_9.tar.gz \
  && cd /usr/local/bin \
  && cp ~/kindlegen /usr/local/bin

# ==============================================================================
# softcover gem
# ==============================================================================
RUN apt-get install -y libxslt-dev libxml2-dev build-essential
RUN gem install softcover --pre --no-ri --no-rdoc

RUN apt-get install -y biber
# ==============================================================================
# Health check
# ==============================================================================
RUN softcover check

# ==============================================================================
# Ready to run
# ==============================================================================
RUN mkdir /book
WORKDIR /book

ENV PATH="$HOME/bin:$PATH"

RUN sudo dpkg-reconfigure locales
ENV LC_CTYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8

EXPOSE 4000

# from book directory build html:
# $ docker run -v `pwd`:/book softcover:latest sc build:html

# run server:
# $ docker run -v `pwd`:/book -d -p 4000:4000 softcover:latest sc server
