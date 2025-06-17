FROM php:8.2-cli

# Install required PHP extensions
RUN apt-get update && apt-get install -y \
    unzip \
    zip \
    git \
    curl \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    && docker-php-ext-install pdo pdo_mysql zip mbstring exif pcntl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy all files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Generate app key if not present (skip error if already set)
RUN php artisan key:generate || true

# Set permissions for storage and bootstrap
RUN chmod -R 755 storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache

# Expose port 8080
EXPOSE 8080

# Start Laravel's built-in PHP server
CMD php artisan serve --host=0.0.0.0 --port=8080
