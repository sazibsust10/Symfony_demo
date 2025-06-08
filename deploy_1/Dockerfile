# 
FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libzip-dev libpq-dev libonig-dev \
    && docker-php-ext-install intl pdo pdo_pgsql zip opcache

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy files and install PHP deps

COPY . .

RUN composer install --no-interaction --optimize-autoloader
 
# Permissions
RUN chown -R www-data:www-data /var/www/html

CMD ["php-fpm"]
