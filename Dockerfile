FROM trafex/php-nginx:latest

LABEL Maintainer="Peter Knut"
LABEL Description="AdminNeo database management"

ARG TARGETPLATFORM

# Temporary switch to root
USER root

# Upgrade base packages first. PHP extensions depend on php85-common without a version, so installing them
# on top of an outdated base image would mix a new extension with an old PHP binary.
RUN apk upgrade --no-cache \
    # Install dependencies
    && apk add --no-cache \
        git \
        php85-pgsql \
        php85-simplexml \
        php85-sqlite3 \
        php85-bz2 \
        php85-zip \
        php85-pecl-mongodb \
        # PECL dependencies
        php85-pear php85-dev  \
        gnupg autoconf g++ make unixodbc-dev \
    # https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver16&tabs=alpine18-install%2Calpine17-install%2Cdebian8-install%2Credhat7-13-install%2Crhel7-offline
    # Download MSSQL packages
    && architecture=${TARGETPLATFORM:6} \
    && curl -O https://download.microsoft.com/download/9dcab408-e0d4-4571-a81a-5a0951e3445f/msodbcsql18_18.6.1.1-1_$architecture.apk \
    && curl -O https://download.microsoft.com/download/9dcab408-e0d4-4571-a81a-5a0951e3445f/msodbcsql18_18.6.1.1-1_$architecture.sig \
    # Verify signature
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --import - \
    && gpg --verify msodbcsql18_18.6.1.1-1_$architecture.sig msodbcsql18_18.6.1.1-1_$architecture.apk \
    # Install the packages
    && apk add --allow-untrusted msodbcsql18_18.6.1.1-1_$architecture.apk \
    && rm msodbcsql18_18.6.1.1-1_$architecture.apk msodbcsql18_18.6.1.1-1_$architecture.sig \
    # Install sqlsrv
    && pecl85 install sqlsrv \
    # Cleanup
    && apk del \
        php85-pear php85-dev \
        gnupg autoconf g++ make unixodbc-dev

COPY src/php.ini ${PHP_INI_DIR}/conf.d/custom.ini
RUN sed -i '/keepalive_timeout/a\    client_max_body_size 1G;' /etc/nginx/nginx.conf

# Fail the build if any PHP extension cannot be loaded
RUN if php -m 2>&1 | grep -iE 'warning|error'; then exit 1; fi \
    && for ext in pgsql sqlite3 mongodb sqlsrv bz2 zip simplexml; do \
        php -m | grep -qix "$ext" || { echo "Missing PHP extension: $ext"; exit 1; }; \
    done

# Switch back to non-root user
USER nobody

# Install AdminNeo dev
ARG GIT_TAG=main
ARG CACHE_BUST=1
RUN git clone --branch ${GIT_TAG} --single-branch --depth 1 https://github.com/adminneo-org/adminneo.git \
    && php adminneo/bin/compile.php mysql,pgsql,mssql,sqlite,mongo,elastic,clickhouse,simpledb -o index.php \
    && rm -rf adminneo \
    && rm test.html

# Copy configuration files
COPY src/adminneo-*.php /var/www/html/
#COPY src/info.php /var/www/html/
