FROM php:8.2-apache

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN a2enmod rewrite

# Configure Apache for proper directory access
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    echo "<Directory /var/www/html>" >> /etc/apache2/apache2.conf && \
    echo "    Options Indexes FollowSymLinks" >> /etc/apache2/apache2.conf && \
    echo "    AllowOverride All" >> /etc/apache2/apache2.conf && \
    echo "    Require all granted" >> /etc/apache2/apache2.conf && \
    echo "</Directory>" >> /etc/apache2/apache2.conf && \
    echo "<Directory /var/www/html/api>" >> /etc/apache2/apache2.conf && \
    echo "    Options Indexes FollowSymLinks" >> /etc/apache2/apache2.conf && \
    echo "    AllowOverride All" >> /etc/apache2/apache2.conf && \
    echo "    Require all granted" >> /etc/apache2/apache2.conf && \
    echo "</Directory>" >> /etc/apache2/apache2.conf

# Copy application files
COPY app/ /var/www/html/

# Ensure API directory exists and has correct permissions
RUN mkdir -p /var/www/html/api && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    find /var/www/html -type f -name "*.php" -exec chmod 644 {} \;

# Create test files for debugging
RUN echo "<?php echo json_encode(['status' => 'API directory accessible', 'time' => date('Y-m-d H:i:s')]); ?>" > /var/www/html/api/test.php

# Create index.html if missing
RUN if [ ! -f /var/www/html/index.html ]; then \
    echo '<!DOCTYPE html><html><head><title>Blood Pressure App</title></head><body>' > /var/www/html/index.html && \
    echo '<h1>🩺 Blood Pressure Measurement System</h1>' >> /var/www/html/index.html && \
    echo '<p>✅ Application is running on Railway!</p>' >> /var/www/html/index.html && \
    echo '<h3>Test Links:</h3>' >> /var/www/html/index.html && \
    echo '<ul>' >> /var/www/html/index.html && \
    echo '<li><a href="/api/test.php">Test API Directory</a></li>' >> /var/www/html/index.html && \
    echo '<li><a href="/api/blood_pressure.php?action=setup">Setup Database</a></li>' >> /var/www/html/index.html && \
    echo '<li><a href="/api/blood_pressure.php?test">Test DB Connection</a></li>' >> /var/www/html/index.html && \
    echo '</ul></body></html>' >> /var/www/html/index.html; \
    fi

EXPOSE 80
CMD ["apache2-foreground"]