FROM mcr.microsoft.com/windows/servercore/insider:10.0.18356.1
#NanoServer can NOT run 32-bit NGINX! 64-bit NGINX not provided by project itself
#FROM mcr.microsoft.com/windows/nanoserver/insider:10.0.18356.1
LABEL maintainer="Ferdi Oeztuerk foerdi@gmail.com"

# jwilder uses this nginx version
ENV NGINX_VERSION 1.14.1

# latest and greatest nginx
#ENV NGINX_VERSION 1.15.9
ENV DOCKER_GEN_VERSION 0.7.4
ENV PWSH_CORE_VERSION 6.1.3
ENV DHPARAM_BITS 2048

ENV PATH C:\\Windows\\System32;C:\\Windows;C:\\pwsh;C:\\nginx;C:\\forego;C:\\openssl;C:\\app;C:\\docker-gen

# Download PowerShell Core
RUN curl.exe -kfSL -o pwsh.zip https://github.com/PowerShell/PowerShell/releases/download/v%PWSH_CORE_VERSION%/PowerShell-%PWSH_CORE_VERSION%-win-x64.zip && \
  mkdir "C:\pwsh" && \
  tar.exe -xf pwsh.zip -C "C:\pwsh"

# Download Nginx
RUN curl.exe -kfSL -o nginx.zip http://nginx.org/download/nginx-%NGINX_VERSION%.zip && \
  tar.exe -xf nginx.zip -C "C:" && \
  ren nginx-%NGINX_VERSION% nginx

#COPY nginx.conf C:/nginx/conf/

# Download forego
RUN curl.exe -kfSL -o forego.zip https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-windows-amd64.zip && \
  mkdir "C:\forego" && \
  tar.exe -xf forego.zip -C "C:\forego"

# Download docker-gen(-windows) in specified version
RUN curl.exe -kfSL -o docker-gen.exe https://github.com/ferdiozturk/docker-gen-windows/releases/download/%DOCKER_GEN_VERSION%-windows/docker-gen.exe && \
  mkdir "C:\docker-gen" && \
  move docker-gen.exe C:\docker-gen

# Download openssl
RUN curl.exe -kfSL -o openssl.zip http://wiki.overbyte.eu/arch/openssl-1.1.1b-win64.zip && \
  mkdir "C:\openssl" && \
  tar.exe -xf openssl.zip -C "C:\openssl"

COPY network_internal.conf C:/nginx/conf/

# Setting DOCKER_HOST on Windows is a little bit more complicated than under Linux
# Change the Docker "daemon.json" according to this URL before using 127.0.0.1:2375
# https://dille.name/blog/2017/11/29/using-the-docker-named-pipe-as-a-non-admin-for-windowscontainers/
#ENV DOCKER_HOST tcp://host.docker.internal:2375

VOLUME ["C:/nginx/certs", "C:/nginx/dhparam"]

COPY . C:/app/
WORKDIR C:/app/

SHELL ["pwsh.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]

ENTRYPOINT "C:\app\docker-entrypoint.ps1"
CMD ["forego", "start", "-r"]
