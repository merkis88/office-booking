# Office Booking (Laravel API) 

> **ВАЖНО:** **не устанавливайте** PHP, MySQL, Nginx/Apache на свой ПК.  
> **Не используйте** XAMPP/WAMP/OSPanel и не запускайте проект локально через `php artisan serve`.  
> Мы работаем **только через Docker** - так у всех одинаковое окружение.

---

## Быстрый старт

### 1) Клонируем репозиторий
```bash
git clone <ссылка на репо>
cd office-booking
```

### 2) Настраиваем .env
```bash
docker compose up -d --build
```

### 3) Поднимаем контейнеры
```bash
docker compose up -d --build
```
### 4) Устанавливаем зависимости и генерим ключ
```bash
docker compose exec laravel.test composer install
docker compose exec laravel.test php artisan key:generate
```
### 5) Поднимаем БД и сиды
```bash
docker compose exec laravel.test php artisan migrate --seed
```

**После выполнения миграций и сидов будут созданы тестовые пользователи:**

Admin: `admin@admin.com / password`

User: `user@user.com / password`

---

## **Как попасть в Swagger**

Swagger доступен **после запуска контейнеров**.

**URL SWAGGER:** `http://localhost:8088/`

---

## **Как не развалить окружение**

>- Если добавил новую миграцию/таблицу
>1) Сначала проверяешь у себя: `docker compose exec laravel.test php artisan migrate`
>2) Только если всё ок - пушишь изменения в git.

>- Если всё сломалось - сбросить базу и пересоздать:
> `docker compose exec laravel.test php artisan migrate:fresh --seed`

>- Не менять порты в docker-compose.yml без согласования, если кто-то сменить порт, у других всё слетит.

>- Не коммитить файл .env. У каждого свои ключи. Этот файл лично для каждого.

>- Не изменять файлы в папке vendor.

