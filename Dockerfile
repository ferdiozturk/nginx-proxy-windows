FROM mcr.microsoft.com/windows/nanoserver:latest
LABEL maintainer="Ferdi Oeztuerk foerdi@gmail.com"

ENV NGINX_VERSION 1.15.9
ENV DOCKER_GEN_VERSION 0.7.4

# Download Nginx
RUN curl.exe -o nginx.zip http://nginx.org/download/nginx-$($env:NGINX_VERSION).zip && \
  mkdir "C:\\Program Files\\nginx" && \
  tar.exe -xf nginx.zip -C "C:\\Program Files\\nginx" --strip-components=1

ENV PATH “C:\\Program Files\\nginx:%PATH%”

# Download GnuWin "sed: stream editor"
RUN curl.exe -o sed.zip https://sourceforge.net/projects/gnuwin32/files/sed/4.2.1/sed-4.2.1-bin.zip/download && \
  mkdir "C:\\Program Files\\sed" && \
  tar.exe -xf sed.zip -C "C:\\Program Files\\sed" --strip-components=1

# Add sed to PATH
ENV PATH “C:\\Program Files\\sed:%PATH%”

# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> C:\Program Files\nginx\nginx.conf \
 && sed -i 's/worker_processes  1/worker_processes  auto/' C:\Program Files\nginx\nginx.conf

# Download forego
RUN curl.exe -o forego.zip https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-windows-amd64.zip && \
  mkdir "C:\\Program Files\\forego" && \
  tar.exe -xf forego.zip -C "C:\\Program Files\\forego" --strip-components=1

# Add forego to PATH
ENV PATH “C:\\Program Files\\forego:%PATH%”

# Download docker-gen in above specified version
RUN curl.exe -o docker-gen.zip https://github.com/ferdiozturk/docker-gen/releases/download/$($env:DOCKER_GEN_VERSION)/docker-gen-windows-amd64-$($env:DOCKER_GEN_VERSION).zip && \
  mkdir "C:\\Program Files\\docker-gen" && \
  tar.exe -xf nginx.zip -C "C:\\Program Files\\docker-gen" --strip-components=1

ENV PATH “C:\\Program Files\\docker-gen:%PATH%”

COPY network_internal.conf "C:\\Program Files\\nginx\\conf"

# Setting DOCKER_HOST on Windows is a little bit more complicated than under Linux
# Change the Docker "daemon.json" according to this URL before using 127.0.0.1:2375
# https://dille.name/blog/2017/11/29/using-the-docker-named-pipe-as-a-non-admin-for-windowscontainers/
ENV DOCKER_HOST tcp://127.0.0.1:2375

VOLUME ["%APPDATA%\\nginx\\certs", "%APPDATA%\\nginx\\dhparam"]

ENTRYPOINT ["docker-entrypoint.ps1"]
CMD ["forego", "start", "-r"]
