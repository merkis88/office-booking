# Office Booking

> **ВАЖНО:** **Не устанавливайте** PHP, MySQL, Nginx/Apache на свой ПК.
> **Не используйте** XAMPP/WAMP/OSPanel.
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

> **Важно:** `vendor/` хранится в Docker volume (`sail-vendor`), а не на хосте.
> После `composer install/update` на хосте нужно повторить команду внутри контейнера.

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

## Архитектура

```
Browser → Nginx (порт 80)
             ├── /           → public/index.html (Vue SPA)
             ├── /dist/*     → public/dist/ (JS, CSS, картинки — собранные Vite)
             ├── /api/*      → php контейнер (PHP-FPM, порт 9000)
             ├── /storage/*  → public/storage/ (загруженные файлы)
             ├── /swagger/   → Swagger UI (встроен в web-контейнер)
             └── /pma/       → phpMyAdmin контейнер
```

---

## Контейнеры

| Сервис         | Образ              | Описание                                  |
|----------------|--------------------|-------------------------------------------|
| **php**        | PHP 8.2-FPM Alpine | Laravel API (FastCGI на порту 9000)       |
| **web**        | Nginx (Alpine)     | Reverse proxy, раздача Vue SPA и статики  |
| **mysql**      | MySQL 8.0          | База данных                               |
| **phpmyadmin** | phpMyAdmin         | Управление БД через браузер               |

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

# Установка PHP-зависимостей (внутри контейнера!)
docker compose exec php composer install

# Тесты
docker compose exec php php artisan test
docker compose exec php php artisan test --filter=TestClassName

# Линтер (Laravel Pint)
docker compose exec php ./vendor/bin/pint

# Очистка кеша роутов (если API возвращает 404)
docker compose exec php php artisan route:clear
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

## Структура каталога `public/`

```
public/
  index.html       ← Vue SPA (генерируется Vite при билде)
  index.php        ← Laravel entry point (используется PHP-FPM)
  favicon.ico
  robots.txt
  dist/            ← Собранные Vite assets (JS, CSS, картинки с хешами)
```

> `dist/` и `index.html` генерируются при `npm run build` и добавлены в `.gitignore`.

---

## Фронтенд (Vue)

Фронтенд написан на Vue 3 + Vite. Исходники лежат в `src/`.

При билде Vite генерирует:
- `public/index.html` — точка входа SPA
- `public/dist/` — JS, CSS, картинки (с хешами для кеширования)

```bash
# Установить зависимости (один раз)
npm install

# Собрать фронтенд (production)
npm run build

# Режим разработки — автосборка при изменениях
npm run dev
```

В режиме `npm run dev` Vite следит за изменениями в `src/` и автоматически пересобирает. Чтобы увидеть изменения в браузере — перезагрузите страницу (F5).

### Изображения

Все изображения хранятся в `src/assets/images/`:
- `icons/` — SVG-иконки
- `photos/` — растровые изображения (PNG, JPG)
- `logo.svg` — логотип

В компонентах используются через `src="@/assets/images/..."`. При билде Vite включает их в `public/dist/` с хешами в именах.

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

## Конфигурация Docker

Конфигурационные файлы лежат в `docker/`:

```
docker/
  web/
    Dockerfile        # Образ nginx (reverse proxy)
    nginx.conf        # Маршрутизация: / → Vue, /api/ → PHP-FPM, /swagger/, /pma/
  php/
    Dockerfile        # Образ PHP 8.2-FPM Alpine + OPcache
    php.ini           # Настройки PHP (лимиты загрузки, OPcache, JIT)
    php-fpm.conf      # Настройки PHP-FPM (пул воркеров)
```

### Как вносить изменения

После редактирования любого файла в `docker/` нужно пересобрать контейнеры:

```bash
# Пересобрать и перезапустить все контейнеры
docker compose up -d --build

# Пересобрать только конкретный контейнер
docker compose up -d --build web   # если менял nginx.conf
docker compose up -d --build php   # если менял php.ini, php-fpm.conf или Dockerfile
```

### Что где настраивается

| Файл | Что можно менять |
|------|------------------|
| `docker/web/nginx.conf` | Маршрутизация URL, gzip, лимит загрузки (`client_max_body_size`), таймауты proxy |
| `docker/php/php.ini` | Лимиты загрузки (`upload_max_filesize`, `post_max_size`), OPcache, JIT |
| `docker/php/php-fpm.conf` | Количество воркеров (`pm.max_children`), стратегия запуска (`pm = dynamic/static`) |

### Производительность (WSL2)

`vendor/` хранится в Docker named volume (`sail-vendor`), а не на примонтированной файловой системе Windows. Это критично для производительности на WSL2 — чтение vendor с `/mnt/c/` в 10+ раз медленнее.

Если после `composer install` на хосте API перестал работать:
```bash
docker compose exec php composer install
```

---

## Как не развалить окружение

- **Добавил миграцию?** Сначала проверь у себя: `docker compose exec php php artisan migrate`. Если ок — пушь.
- **Всё сломалось?** Сбрось базу: `docker compose exec php php artisan migrate:fresh --seed`
- **API возвращает 404?** Очисти кеш роутов: `docker compose exec php php artisan route:clear`
- **Не меняй порты** в `docker-compose.yml` без согласования — у других всё слетит.
- **Не коммить `.env`** — у каждого свои ключи.
- **Не трогай `vendor/`** на хосте напрямую — он в Docker volume. Используй `docker compose exec php composer ...`
