**!!! Не надо устанавливать PHP, MySQL или Nginx на свои пк. Работаем через докер !!!**

1) `git clone <ссылка> && cd office-booking`

2) `cp .env.example .env` - ничего менять внутри не надо

3) Поднимаем контейнеры: `docker compose up -d --build`

4) Устанавливаем зависимости и ключи

   ```bash
    docker compose exec laravel.test composer install
    docker compose exec laravel.test php artisan key:generate
   ```

5) БД: 
   ```bash
    docker compose exec laravel.test php artisan migrate --seed
   ```

После выполения 5 пункта, будет создана admin и user. 
**Admin:** `admin@admin.com` / `password`
**User:** `user@user.com` / `password`

**!!! Что делать, чтобы окружение не развалилось:**

1) **Если ты добавил новую таблицу:**
   Сначала проверяешь у себя:
   `docker compose exec laravel.test php artisan migrate`
   Только если всё ок — пушишь в гит.

   Если ты скачал обновления git pull и там новые миграции:
   Обязательно обновляешь свою базу той же командой:
   `docker compose exec laravel.test php artisan migrate`

2) **Если всё сломалось** 
  Команда, которая удаляет всё и создает чистую базу заново:
 `docker compose exec laravel.test php artisan migrate:fresh --seed`

**!!! Что не делать:**

1) Не менять порты в docker-compose.yml без согласования, если кто-то сменить порт, у других всё слетит.
2) Не коммитить файл .env. У каждого свои ключи. Этот файл лично для каждого.
3) Не изменять файлы в папке vendro.
4) Фронты не лезут к бэкам. Если нужны данные, просите сидер.
