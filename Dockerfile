FROM php:8.4-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git unzip zip libicu-dev libonig-dev libxml2-dev libzip-dev curl \
    && docker-php-ext-install intl pdo pdo_mysql zip opcache

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy app files
COPY . .

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Permissions
RUN chown -R www-data:www-data /var/www/html/var /var/www/html/vendor

EXPOSE 9000

CMD ["php-fpm"]
