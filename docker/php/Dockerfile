FROM php:8.2.30-fpm-alpine

# Зависимости для PHP-расширений
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    mysql-client

# PHP-расширения для Laravel
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    pdo_mysql \
    mbstring \
    zip \
    gd \
    intl \
    bcmath \
    pcntl

# Composer
COPY --from=composer:2.9.5 /usr/bin/composer /usr/bin/composer

# Конфиги
COPY php.ini /usr/local/etc/php/php.ini
COPY php-fpm.conf /usr/local/etc/php-fpm.d/zz-custom.conf

# Рабочая директория (должна совпадать с root в nginx)
WORKDIR /app

# Создать директории для php-fpm
RUN mkdir -p /app/run /app/tmp
