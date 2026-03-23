FROM php:8.2.30-fpm-alpine

# Зависимости для PHP-расширений
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    mysql-client \
    tzdata

# PHP-расширения для Laravel
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    pdo_mysql \
    mbstring \
    zip \
    gd \
    intl \
    bcmath \
    pcntl \
    opcache

# Composer
COPY --from=composer:2.9.5 /usr/bin/composer /usr/bin/composer

# Конфиги
COPY php.ini /usr/local/etc/php/php.ini
COPY php-fpm.conf /usr/local/etc/php-fpm.d/zz-custom.conf

ENV TZ=Asia/Tomsk
ENV APP_TIMEZONE=Asia/Tomsk
ENV BC_TIMEZONE=Asia/Tomsk

WORKDIR /app

EXPOSE 9000
