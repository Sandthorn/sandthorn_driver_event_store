FROM ruby:2.5

WORKDIR .

ENV http_proxy "http://wwwproxy.se.axis.com:3128/"
ENV NO_PROXY "localhost,127.0.0.1,se.axis.com"
ENV HTTPS_PROXY "http://wwwproxy.se.axis.com:3128/"
ENV HTTP_PROXY "http://wwwproxy.se.axis.com:3128/"

RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "sqlite3"]

RUN ["gem", "install", "bundler"]

CMD ["/bin/bash"]

