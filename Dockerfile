FROM mcr.microsoft.com/windows/nanoserver/insider:10.0.18356.1
LABEL maintainer="Ferdi Oeztuerk foerdi@gmail.com"

ENV NGINX_VERSION 1.15.9
ENV DOCKER_GEN_VERSION 0.7.4

ENV PATH C:\\Windows\\System32;C:\\Windows;C:\\nginx-${NGINX_VERSION};C:\\gawk\\bin;C:\\forego

# Download Nginx
RUN curl.exe -kfSL -o nginx.zip http://nginx.org/download/nginx-%NGINX_VERSION%.zip && \
  tar.exe -xf nginx.zip -C "C:"

# UNUSED Download GnuWin "sed: stream editor"
#RUN curl.exe -kfSL -o sed.zip https://sourceforge.net/projects/gnuwin32/files/sed/4.2.1/sed-4.2.1-bin.zip/download && \
#  mkdir "C:\sed" && \
#  tar.exe -xf sed.zip -C "C:\sed"

# UNUSED Download GnuWin "Gawk: pattern scanning and processing language"
#RUN curl.exe -kfSL -o gawk.zip https://sourceforge.net/projects/gnuwin32/files/gawk/3.1.6-1/gawk-3.1.6-1-bin.zip/download && \
#  mkdir "C:\gawk" && \
#  tar.exe -xf gawk.zip -C "C:\gawk"

# Configure Nginx and apply fix for very long server names
#RUN echo "daemon off;" >> C:\nginx-1.15.9\conf\nginx.conf && \
#  sed.exe -i "s/worker_processes  1/worker_processes  auto/" C:\nginx-1.15.9\conf\nginx.conf
COPY nginx.conf C:/nginx-%NGINX_VERSION%/conf/

# Download forego
RUN curl.exe -kfSL -o forego.zip https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-windows-amd64.zip && \
  mkdir "C:\forego" && \
  tar.exe -xf forego.zip -C "C:\forego"

# Download docker-gen(-windows) in specified version
RUN curl.exe -kfSL -o docker-gen.exe https://github.com/ferdiozturk/docker-gen-windows/releases/download/%DOCKER_GEN_VERSION%-windows/docker-gen.exe

COPY network_internal.conf C:/nginx-%NGINX_VERSION%/conf/

# Setting DOCKER_HOST on Windows is a little bit more complicated than under Linux
# Change the Docker "daemon.json" according to this URL before using 127.0.0.1:2375
# https://dille.name/blog/2017/11/29/using-the-docker-named-pipe-as-a-non-admin-for-windowscontainers/
ENV DOCKER_HOST tcp://127.0.0.1:2375

VOLUME ["C:/nginx/certs", "C:/nginx/dhparam"]

ENTRYPOINT ["docker-entrypoint.ps1"]
CMD ["forego", "start", "-r"]
