FROM trafex/php-nginx:latest

LABEL Maintainer="Peter Knut"
LABEL Description="AdminNeo database management"

ARG TARGETPLATFORM

# Temporary switch to root
USER root

# Install dependencies
RUN apk add --update --no-cache \
        git \
        php84-pgsql \
        php84-simplexml \
        php84-bz2 \
        php84-zip \
        php84-pecl-mongodb \
        # PECL dependencies
        php84-pear php84-dev  \
        gnupg autoconf g++ make unixodbc-dev \
    # https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver16&tabs=alpine18-install%2Calpine17-install%2Cdebian8-install%2Credhat7-13-install%2Crhel7-offline
    # Download MSSQL packages
    && architecture=${TARGETPLATFORM:6} \
    && curl -O https://download.microsoft.com/download/fae28b9a-d880-42fd-9b98-d779f0fdd77f/msodbcsql18_18.5.1.1-1_$architecture.apk \
    && curl -O https://download.microsoft.com/download/fae28b9a-d880-42fd-9b98-d779f0fdd77f/msodbcsql18_18.5.1.1-1_$architecture.sig \
    # Verify signature
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --import - \
    && gpg --verify msodbcsql18_18.5.1.1-1_$architecture.sig msodbcsql18_18.5.1.1-1_$architecture.apk \
    # Install the packages
    && apk add --allow-untrusted msodbcsql18_18.5.1.1-1_$architecture.apk \
    && rm msodbcsql18_18.5.1.1-1_$architecture.apk msodbcsql18_18.5.1.1-1_$architecture.sig \
    # Install sqlsrv
    && pecl84 install sqlsrv \
    # Cleanup
    && apk del \
        php84-pear php84-dev \
        gnupg autoconf g++ make unixodbc-dev

COPY src/php.ini ${PHP_INI_DIR}/conf.d/custom.ini
RUN sed -i '/keepalive_timeout/a\    client_max_body_size 1G;' /etc/nginx/nginx.conf
RUN sed -i -e 's/8080/80/g' /etc/nginx/conf.d/default.conf

# Switch back to non-root user
USER nobody

# Install composer from the official image
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install AdminNeo dev
ARG CACHE_BUST=1
RUN git clone --single-branch --depth 1 https://github.com/adminneo-org/adminneo.git \
    && composer install -d adminneo --optimize-autoloader --no-interaction --no-progress \
    && php adminneo/bin/compile.php mysql,pgsql,mssql,mongo,elastic,clickhouse,simpledb default+ \
    && mkdir plugins \
    && cp adminneo/export/adminneo.php . \
    && cp adminneo/plugins/*.php plugins \
    && rm -rf adminneo \
    && rm test.html

# Copying index.php
COPY src/index.php /var/www/html/
#COPY src/info.php /var/www/html/

EXPOSE 80
