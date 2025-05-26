FROM php:8.2-apache

# Install PHP extensions and dependencies
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install -j$(nproc) \
    intl \
    pdo_mysql \
    mysqli \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite headers

# Configure Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    echo "<Directory /var/www/html>" >> /etc/apache2/apache2.conf && \
    echo "    Options Indexes FollowSymLinks" >> /etc/apache2/apache2.conf && \
    echo "    AllowOverride All" >> /etc/apache2/apache2.conf && \
    echo "    Require all granted" >> /etc/apache2/apache2.conf && \
    echo "</Directory>" >> /etc/apache2/apache2.conf

# Configure PHP
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    sed -i 's/memory_limit = 128M/memory_limit = 256M/g' "$PHP_INI_DIR/php.ini" && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/g' "$PHP_INI_DIR/php.ini" && \
    sed -i 's/post_max_size = 8M/post_max_size = 20M/g' "$PHP_INI_DIR/php.ini"

# Copy application files
COPY app/ /var/www/html/

# Create initialization script that runs on container start
RUN echo '#!/bin/bash\n\
    # Update database configuration with Railway environment variables\n\
    if [ ! -z "$MYSQL_URL" ]; then\n\
    # Parse MySQL URL\n\
    MYSQL_URL_REGEX="mysql:\/\/([^:]+):([^@]+)@([^:]+):([^\/]+)\/(.+)"\n\
    if [[ $MYSQL_URL =~ $MYSQL_URL_REGEX ]]; then\n\
    export DB_USER="${BASH_REMATCH[1]}"\n\
    export DB_PASS="${BASH_REMATCH[2]}"\n\
    export DB_HOST="${BASH_REMATCH[3]}"\n\
    export DB_PORT="${BASH_REMATCH[4]}"\n\
    export DB_NAME="${BASH_REMATCH[5]}"\n\
    fi\n\
    fi\n\
    # Update PHP configuration\n\
    sed -i "s/\$host = .*/\$host = \"${DB_HOST:-localhost}\";/g" /var/www/html/api/blood_pressure.php\n\
    sed -i "s/\$dbname = .*/\$dbname = \"${DB_NAME:-blodtrykk}\";/g" /var/www/html/api/blood_pressure.php\n\
    sed -i "s/\$username = .*/\$username = \"${DB_USER:-root}\";/g" /var/www/html/api/blood_pressure.php\n\
    sed -i "s/\$password = .*/\$password = \"${DB_PASS:-}\";/g" /var/www/html/api/blood_pressure.php\n\
    # Start Apache\n\
    apache2-foreground' > /start.sh && chmod +x /start.sh

# Fix permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Railway uses PORT environment variable
ENV PORT=80
EXPOSE 80

# Use the start script as entrypoint
CMD ["/start.sh"]