## Adapted from https://hub.docker.com/r/rocker/r-ver 
FROM debian:jessie

ARG R_VERSION
ARG BUILD_DATE
ENV BUILD_DATE ${BUILD_DATE:-2017-01-07}
ENV R_VERSION ${R_VERSION:-3.3.2}
ENV LC_ALL es_ES.UTF-8
ENV LANG es_ES.UTF-8
ENV TERM xterm

# Dockerfile author / maintainer 
MAINTAINER Carlos P. <cpgonzal@gmail.com> 

## Set a default user. Available via runtime flag `--user docker` 
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly). 

RUN  groupadd -r -g 1100 docker \
        && useradd -g docker -u 1100 docker \
  && mkdir /home/docker \
  && chown docker:docker /home/docker \
  && addgroup docker staff

## Install needed packages and dependencies
RUN apt-get update \ 
    && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates curl \
    file \
    fonts-texgyre \
    g++ \
    gfortran \
    gsfonts \
    libbz2-1.0 \
    libcurl3 \
    libicu52 \
    libjpeg62-turbo \
    libopenblas-dev \
    libpangocairo-1.0-0 \ 
    libpcre3 \
    libpng12-0 \
    libtiff5 \ 
    liblzma5 \
    locales \
    make \
    unzip \
    zip \
    vim-tiny \
    zlib1g \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ 

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen es_ES.utf8 \
  && /usr/sbin/update-locale LANG=es_ES.UTF-8 

ENV LC_ALL es_ES.UTF-8
ENV LANG es_ES.UTF-8
ENV TERM xterm

## Build R-base with dependencies
RUN BUILDDEPS="curl \
    default-jdk \
    libbz2-dev \
    libcairo2-dev \ 
    libcurl4-openssl-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libicu-dev \
    libpcre3-dev \
    libpng-dev \
    libreadline-dev \
    libtiff5-dev \
    liblzma-dev \ 
    libx11-dev \
    libxt-dev \
    perl \
    texinfo \
    texlive-extra-utils \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-recommended \
    x11proto-core-dev \
    xauth \
    xfonts-base \
    xvfb \
    zlib1g-dev" \
  && apt-get update \ 
  && apt-get install -y --no-install-recommends $BUILDDEPS \ 
  && cd tmp/ \
  ## Download source code 
  && curl -O https://cran.r-project.org/src/base/R-3/R-${R_VERSION}.tar.gz \
  ## Extract source code
  && tar -xf R-${R_VERSION}.tar.gz \
  && cd R-${R_VERSION} \
  ## Set compiler flags
  && R_PAPERSIZE=letter \
    R_BATCHSAVE="--no-save --no-restore" \
    R_BROWSER=xdg-open \
    PAGER=/usr/bin/pager \
    PERL=/usr/bin/perl \
    R_UNZIPCMD=/usr/bin/unzip \
    R_ZIPCMD=/usr/bin/zip \
    R_PRINTCMD=/usr/bin/lpr \
    LIBnn=lib \
    AWK=/usr/bin/awk \
    CFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
    CXXFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
  ## Configure options
  ./configure --enable-R-shlib \
               --enable-memory-profiling \
               --with-readline \
               --with-blas="-lopenblas" \
               --disable-nls \
               --without-recommended-packages \
  ## Build and install
  && make \
  && make install \
  ## Add a default CRAN mirror
  && echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'curl')" >> /usr/local/lib/R/etc/Rprofile.site \
  ## Add a library directory (for user-installed packages)  
  ## Fix library path and add R_LIBS variable to Renviron
  && echo "R_LIBS_USER='/usr/local/lib/R/library'" >> /usr/local/lib/R/etc/Renviron \
  && echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron \
  ## install packages from date-locked MRAN snapshot of CRAN
  && [ -z "$BUILD_DATE" ] && BUILD_DATE=$(date -I --date='TZ="Atlantic/Canary"') || true \
  && MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE} \
  && echo MRAN=$MRAN >> /etc/environment \
  && echo "options(repos = c(CRAN='$MRAN'), download.file.method = 'curl')" >> /usr/local/lib/R/etc/Rprofile.site \
  ## Use littler installation scripts
  && echo 'source("/usr/local/lib/R/etc/Rprofile.site")' >> /etc/littler.r \
  && Rscript -e "install.packages(c('littler', 'docopt'), lib='/usr/local/lib/R/library', repo = '$MRAN')" \
  && ln -s /usr/local/lib/R/library/littler/examples/install2.r /usr/local/bin/install2.r \
  && ln -s /usr/local/lib/R/library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
  && ln -s /usr/local/lib/R/library/littler/bin/r /usr/local/bin/r \
  ## Clean up from R source install
  && cd / \
  && rm -rf /tmp/* \
  && apt-get remove --purge -y $BUILDDEPS \
  && apt-get autoremove -y \
  && apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/* \
  #Assigns write permission to group
  && echo "umask 0002" >> /etc/bash.bashrc

CMD ["R"]