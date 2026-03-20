# Office Booking

> **ВАЖНО:** **Не устанавливайте** PHP, MySQL, Nginx/Apache на свой ПК.
> **Не используйте** XAMPP/WAMP/OSPanel и не запускайте проект локально через `php artisan serve`.
> Бэкенд работает **только через Docker** — так у всех одинаковое окружение.

---

## Быстрый старт

### 1. Клонируем репозиторий
```bash
git clone <ссылка на репо>
cd office-booking
```

### 2. Настраиваем .env
```bash
cp .env.example .env
```

### 3. Поднимаем контейнеры
```bash
docker compose up -d --build
```

### 4. Устанавливаем PHP-зависимости и генерируем ключ
```bash
docker compose exec php composer install
docker compose exec php php artisan key:generate
```

### 5. Поднимаем БД и сиды
```bash
docker compose exec php php artisan migrate --seed
```

### 6. Собираем фронтенд
```bash
npm install
npm run build
```

**Тестовые пользователи (после seed):**

| Роль  | Email               | Пароль     |
|-------|---------------------|------------|
| Admin | `admin@admin.com`   | `password` |
| User  | `user@user.com`     | `password` |

---

## Контейнеры

| Сервис       | Контейнер    | Описание                          |
|--------------|--------------|-----------------------------------|
| **php**      | PHP 8.2-FPM  | Laravel API (FastCGI на порту 9000) |
| **web**      | Nginx        | Веб-сервер, Swagger UI            |
| **mysql**    | MySQL 8.0    | База данных                       |
| **phpmyadmin** | phpMyAdmin | Управление БД через браузер       |

### Управление контейнерами

```bash
# Поднять контейнеры
docker compose up -d --build

# Остановить
docker compose down

# Логи конкретного контейнера
docker compose logs -f php
docker compose logs -f web

# Выполнить artisan-команду
docker compose exec php php artisan <command>

# Миграции
docker compose exec php php artisan migrate --seed

# Сброс БД
docker compose exec php php artisan migrate:fresh --seed

# Установка PHP-зависимостей
docker compose exec php composer install

# Тесты
docker compose exec php php artisan test
docker compose exec php php artisan test --filter=TestClassName

# Линтер (Laravel Pint)
docker compose exec php ./vendor/bin/pint
```

---

## URL-адреса

| Сервис      | URL                        |
|-------------|----------------------------|
| Сайт (Vue)  | `http://localhost/`        |
| Laravel API | `http://localhost/api/`    |
| Swagger UI  | `http://localhost/swagger/` |
| phpMyAdmin  | `http://localhost/pma/`    |

---

## Фронтенд (Vue)

Фронтенд написан на Vue 3 + Vite. Исходники лежат в `src/`, билд собирается в `public/dist/`.

```bash
# Установить зависимости (один раз)
npm install

# Собрать фронтенд (production)
npm run build

# Режим разработки — автосборка при изменениях
npm run dev
```

В режиме `npm run dev` Vite следит за изменениями в `src/` и автоматически пересобирает `public/dist/`. Чтобы увидеть изменения в браузере — перезагрузите страницу (F5).

---

## Swagger

Swagger UI доступен по адресу `http://localhost/swagger/`.

Спецификация загружается из файла `docs/openapi.yaml`. Чтобы обновить документацию:

1. Отредактируйте `docs/openapi.yaml`
2. Перезагрузите страницу Swagger — изменения подтянутся автоматически (файл монтируется в контейнер)

Также можно сгенерировать Swagger из аннотаций в коде:
```bash
docker compose exec php php artisan l5-swagger:generate
```

### Авторизация в Swagger

1. Получите токен — выполните в терминале:
```bash
curl -s -X POST http://localhost/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@admin.com","password":"password"}' \
  | grep -o '"token":"[^"]*"'
```
2. Скопируйте значение токена из ответа
3. В Swagger нажмите кнопку **Authorize** (замок вверху страницы)
4. Введите: `Bearer <ваш_токен>`
5. Теперь защищённые эндпоинты доступны

---

## Конфигурация Nginx и PHP

Конфигурационные файлы лежат в `docker/`:

```
docker/
  web/
    Dockerfile        # Образ веб-сервера (на базе nginx)
    nginx.conf        # Конфигурация Nginx
  php/
    Dockerfile        # Образ PHP 8.2-FPM
    php.ini           # Настройки PHP (лимиты загрузки, OPcache, JIT)
    php-fpm.conf      # Настройки PHP-FPM (пул воркеров)
```

### Как вносить изменения

После редактирования любого файла в `docker/` нужно пересобрать контейнеры:

```bash
# Пересобрать и перезапустить все контейнеры
docker compose up -d --build

# Пересобрать только конкретный контейнер
docker compose up -d --build web   # если менял nginx.conf или docker/web/Dockerfile
docker compose up -d --build php   # если менял php.ini, php-fpm.conf или docker/php/Dockerfile
```

### Что где настраивается

| Файл | Что можно менять |
|------|------------------|
| `docker/web/nginx.conf` | Маршрутизация URL, gzip, лимит загрузки (`client_max_body_size`), таймауты FastCGI |
| `docker/php/php.ini` | Лимиты загрузки (`upload_max_filesize`, `post_max_size`), OPcache, JIT |
| `docker/php/php-fpm.conf` | Количество воркеров (`pm.max_children`), стратегия запуска (`pm = dynamic/static`) |

---

## Как не развалить окружение

- **Добавил миграцию?** Сначала проверь у себя: `docker compose exec php php artisan migrate`. Если ок — пушь.
- **Всё сломалось?** Сбрось базу: `docker compose exec php php artisan migrate:fresh --seed`
- **Не меняй порты** в `docker-compose.yml` без согласования — у других всё слетит.
- **Не коммить `.env`** — у каждого свои ключи.
- **Не трогай `vendor/`** — зависимости управляются через Composer.
