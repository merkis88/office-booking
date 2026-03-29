<?php

namespace Database\Seeders;

use App\Models\Parking_place;
use App\Models\ServiceType;
use App\Models\User;
use App\Models\Role;
use App\Models\Place;
use App\Models\Service;
use App\Models\Booking;
use App\Models\Qr;
use App\Models\Review;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $roleAdmin = Role::create(['role_name' => 'admin']);
        $roleUser = Role::create(['role_name' => 'user']);
        $serviceTypeCleaning = ServiceType::create(['name' => 'Клиннинг', 'description' => 'Уборка помещений', 'is_active' => true, 'created_at' => now(), 'updated_at' => now()]);
        $serviceTypeTO = ServiceType::create(['name' => 'ТО', 'description' => 'ТО', 'is_active' => true, 'created_at' => now(), 'updated_at' => now()]);
        $admin = User::create([
            'role_id' => $roleAdmin->id,
            'first_name' => 'Super',
            'last_name' => 'Admin',
            'email' => 'admin@admin.com',
            'password' => Hash::make('password'),
            'post' => 'System Administrator',
            'company' => 'My Company',
            'photo' => 'places/женщина_1.jpg',
            'is_verified' => true,
            'verification_code' => 111111,
            'verification_code_expires_at' => now(),
            'email_verified_at' => now(),
        ]);
        $user1 = User::create([
            'role_id' => $roleUser->id,
            'first_name' => 'Алексей',
            'last_name' => 'Краснов',
            'email' => 'user1@user.com',
            'password' => Hash::make('password'),
            'post' => 'Backend Developer',
            'company' => 'My Company',
            'is_verified' => true,
            'verification_code' => 111111,
            'verification_code_expires_at' => now(),
            'email_verified_at' => now(),
            'photo' => 'places/женщина_11.jpg'
        ]);
        $user2 = User::create([
            'role_id' => $roleUser->id,
            'first_name' => 'Марина',
            'last_name' => 'Цветаева',
            'email' => 'user2@user.com',
            'password' => Hash::make('password'),
            'post' => 'Backend Developer',
            'company' => 'My Company',
            'is_verified' => true,
            'verification_code' => 111111,
            'verification_code_expires_at' => now(),
            'email_verified_at' => now(),
            'photo' => 'places/мужик_1.jpg'
        ]);
        $user3 = User::create([
            'role_id' => $roleUser->id,
            'first_name' => 'Сергей',
            'last_name' => 'Петров',
            'email' => 'user3@user.com',
            'password' => Hash::make('password'),
            'post' => 'Backend Developer',
            'company' => 'My Company',
            'is_verified' => true,
            'verification_code' => 111111,
            'verification_code_expires_at' => now(),
            'email_verified_at' => now(),
            'photo' => 'places/мужик_2.jpg'
        ]);
        $user4 = User::create([
            'role_id' => $roleUser->id,
            'first_name' => 'Екатерина',
            'last_name' => 'Трошенникова',
            'email' => 'user4@user.com',
            'password' => Hash::make('password'),
            'post' => 'Backend Developer',
            'company' => 'My Company',
            'is_verified' => true,
            'verification_code' => 111111,
            'verification_code_expires_at' => now(),
            'email_verified_at' => now(),
            'photo' => 'places/мужик_3.jpg'
        ]);

        $user = User::create([
            'role_id' => $roleUser->id,
            'first_name' => 'Толян',
            'last_name' => 'Ноумов',
            'patronymic' => 'Иванович',
            'email' => 'user@user.com',
            'password' => Hash::make('password'),
            'post' => 'Backend Developer',
            'company' => 'My Company',
            'is_verified' => true,
            'verification_code' => 111111,
            'verification_code_expires_at' => now(),
            'email_verified_at' => now(),
            'photo' => 'places/женщина_8.jpg'
        ]);

        $coworking1 = Place::create([
            'name' => 'Лучший Коворкинг 40',
            'photo' => 'places/коворкинг_1.jpg',
            'type' => 'coworking',
            'capacity' => 40,
            'number_place' => 1,
            'price' => 250,
            'description' => 'Комната для коворкинга с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $coworking2 = Place::create([
            'name' => 'Лучший Коворкинг 55',
            'photo' => 'places/коворкинг_2.jpg',
            'type' => 'coworking',
            'capacity' => 55,
            'number_place' => 2,
            'price' => 350,
            'description' => 'Комната для коворкинга с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $coworking3 = Place::create([
            'name' => 'Лучший Коворкинг 60',
            'photo' => 'places/коворкинг_3.jpg',
            'type' => 'coworking',
            'capacity' => 60,
            'number_place' => 3,
            'price' => 350,
            'description' => 'Комната для коворкинга с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $coworking4 = Place::create([
            'name' => 'НаиЛучший Коворкинг 40',
            'photo' => 'places/коворкинг_4.jpg',
            'type' => 'coworking',
            'capacity' => 40,
            'number_place' => 4,
            'price' => 350,
            'description' => 'Комната для коворкинга с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $coworking5 = Place::create([
            'name' => 'НаиЛучший Коворкинг 60',
            'photo' => 'places/коворкинг_5.jpg',
            'type' => 'coworking',
            'capacity' => 60,
            'number_place' => 5,
            'price' => 350,
            'description' => 'Комната для коворкинга с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $coworking6 = Place::create([
            'name' => 'НаиЛучший Коворкинг 55',
            'photo' => 'places/коворкинг_6.jpg',
            'type' => 'coworking',
            'capacity' => 55,
            'number_place' => 6,
            'price' => 350,
            'description' => 'Комната для коворкинга с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $coworking7 = Place::create([
            'name' => 'НаиЛучший Коворкинг 45',
            'photo' => 'places/коворкинг_7.jpg',
            'type' => 'coworking',
            'capacity' => 45,
            'number_place' => 7,
            'price' => 350,
            'description' => 'Комната для коворкинга с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $coworking8 = Place::create([
            'name' => 'НаиЛучший Коворкинг 50',
            'photo' => 'places/коворкинг_8.jpg',
            'type' => 'coworking',
            'capacity' => 50,
            'number_place' => 8,
            'price' => 250,
            'description' => 'Комната для коворкинга с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $office1 = Place::create([
            'name' => 'Лучший Офис 5',
            'photo' => 'places/офис_5_человек.jpg',
            'type' => 'office',
            'capacity' => 5,
            'number_place' => 9,
            'price' => 900,
            'description' => 'Офис с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $office2 = Place::create([
            'name' => 'НаиЛучший Офис 5',
            'photo' => 'places/офис_5_человек_2.jpg',
            'type' => 'office',
            'capacity' => 5,
            'number_place' => 10,
            'price' => 900,
            'description' => 'Офис с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $office3 = Place::create([
            'name' => 'Лучший Офис 10',
            'photo' => 'places/офис_10_человек.jpg',
            'type' => 'office',
            'capacity' => 10,
            'number_place' => 11,
            'price' => 1600,
            'description' => 'Офис с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $office4 = Place::create([
            'name' => 'НаиЛучший Офис 10',
            'photo' => 'places/офис_10_человек_2.jpg',
            'type' => 'office',
            'capacity' => 10,
            'number_place' => 12,
            'price' => 1600,
            'description' => 'Офис с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $office5 = Place::create([
            'name' => 'Лучший Офис 20',
            'photo' => 'places/офис_20_человек.jpg',
            'type' => 'office',
            'capacity' => 20,
            'number_place' => 13,
            'price' => 2700,
            'description' => 'Офис с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $office6 = Place::create([
            'name' => 'НаиЛучший Офис 20',
            'photo' => 'places/офис_20_человек_2.jpg',
            'type' => 'office',
            'capacity' => 20,
            'number_place' => 14,
            'price' => 2700,
            'description' => 'Офис с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $office7 = Place::create([
            'name' => 'Лучший Офис 40',
            'photo' => 'places/офис_40_человек.jpg',
            'type' => 'office',
            'capacity' => 40,
            'number_place' => 15,
            'price' => 5700,
            'description' => 'Офис с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $office8 = Place::create([
            'name' => 'НаиЛучший Офис 40',
            'photo' => 'places/офис_40_человек_2.jpg',
            'type' => 'office',
            'capacity' => 40,
            'number_place' => 16,
            'price' => 5700,
            'description' => 'Офис с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $meeting1 = Place::create([
            'name' => 'Лучшая Переговорная 5',
            'photo' => 'places/переговорная_5_человек.jpg',
            'type' => 'meeting',
            'capacity' => 5,
            'number_place' => 17,
            'price' => 400,
            'description' => 'Переговорная с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $meeting2 = Place::create([
            'name' => 'Лучшая Переговорная 6',
            'photo' => 'places/переговорная_6_человек.jpg',
            'type' => 'meeting',
            'capacity' => 6,
            'number_place' => 18,
            'price' => 450,
            'description' => 'Переговорная с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $meeting3 = Place::create([
            'name' => 'Лучшая Переговорная 7',
            'photo' => 'places/переговорная_7_человек.jpg',
            'type' => 'meeting',
            'capacity' => 7,
            'number_place' => 19,
            'price' => 700,
            'description' => 'Переговорная с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $meeting4 = Place::create([
            'name' => 'НаиЛучшая Переговорная 7',
            'photo' => 'places/переговорная_7_человек_2.jpg',
            'type' => 'meeting',
            'capacity' => 7,
            'number_place' => 20,
            'price' => 700,
            'description' => 'Переговорная с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $meeting5 = Place::create([
            'name' => 'Лучшая Переговорная 8',
            'photo' => 'places/переговорная_8_человек.jpg',
            'type' => 'meeting',
            'capacity' => 8,
            'number_place' => 21,
            'price' => 750,
            'description' => 'Переговорная с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $meeting6 = Place::create([
            'name' => 'НаиЛучшая Переговорная 8',
            'photo' => 'places/переговорная_8_человек_2.jpg',
            'type' => 'meeting',
            'capacity' => 8,
            'number_place' => 22,
            'price' => 750,
            'description' => 'Переговорная с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $meeting7 = Place::create([
            'name' => 'Лучшая Переговорная 12',
            'photo' => 'places/переговорная_12_человек.jpg',
            'type' => 'meeting',
            'capacity' => 12,
            'number_place' => 23,
            'price' => 1200,
            'description' => 'Переговорная с проектором и маркерной доской',
            'is_active' => true,
        ]);
        $meeting8 = Place::create([
            'name' => 'Лучшая Переговорная 15',
            'photo' => 'places/переговорная_15_человек.jpg',
            'type' => 'meeting',
            'capacity' => 15,
            'number_place' => 24,
            'price' => 1200,
            'description' => 'Переговорная с проектором и маркерной доской',
            'is_active' => true,
        ]);



        $booking = Booking::create([
            'place_id' => $coworking1->id,
            'created_by' => $user->id,
            'user_id' => $user->id,
            'price' => 1000,
            'start_time' => now()->addDay()->setHour(10)->setMinute(0),
            'end_time' => now()->addDay()->setHour(12)->setMinute(0),
            'pass_type' => 'qr',
        ]);
        Service::create([
            'user_id' => $user->id,
            'booking_id' => $booking->id,
            'place_id' => $coworking1->id,
            'service_type_id' => $serviceTypeTO->id,
            'service_date' => now()->addDays(5),
            'service_time' => now()->setHour(10)->setMinute(0),
            'status' => 'pending',
            'comment' => 'Коммент',
        ]);

        Qr::create([
            'booking_id' => $booking->id,
            'hash' => hash('sha256', 'unique_secret_string_' . $booking->id),
            'time_window' => intdiv(now()->timestamp, 1800),
            'used_at' => null,
        ]);
        $review1 = Review::create([
            'text' => 'Просто ужас. QR-код перестал работать прямо на входе, охранник не пропускал, пришлось час доказывать, что я здесь работаю. В приложении номер техподдержки спрятан как сокровище. Больше ни ногой.',
            'rating' => 1,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review2 = Review::create([
            'text' => 'Забронировала место через приложение, оплатила. Прихожу — оно занято. Оказалось, система "проглючила". Администрация разводит руками, деньги возвращать отказываются. Полный кидалово, а не сервис.',
            'rating' => 1,
            'user_id' => $admin->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review3 = Review::create([
            'text' => 'Мне выслали гостевой пропуск, он "сломался" через 10 минут. На ресепшене сказали "обновите приложение" и продолжили пить кофе. В итоге опоздал на важную встречу. Хамство и безразличие на каждом шагу.',
            'rating' => 1,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review4 = Review::create([
            'text' => 'Хотели арендовать переговорную для совещания с клиентами. В системе отображалось, что комната свободна, а на деле там шёл ремонт. Позор! Сорвали переговоры. Сервис не просто сырой, он гнилой.',
            'rating' => 1,
            'user_id' => $admin->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review5 = Review::create([
            'text' => 'Заявку на клининг подал за два дня. В назначенное время никто не пришёл. В приложении статус сменился на "Исполнено". Это что, шутка? Грязь в офисе, а они виртуально убрались.',
            'rating' => 1,
            'user_id' => $admin->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review6 = Review::create([
            'text' => 'Работодатель купил пропуск. В моём профиле компанию и должность нельзя поменять (ошибка в написании). Обратилась в поддержку — месяц тишины. Чувствую себя не сотрудником, а привязанной к ошибке в базе данных.',
            'rating' => 1,
            'user_id' => $admin->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review7 = Review::create([
            'text' => 'Идея хорошая, но исполнение — двойка. Приложение постоянно вылетает, когда пытаешься показать QR-код на входе. Карта парковки грузится минуту. Раздражает, но хоть работает... иногда.',
            'rating' => 2,
            'user_id' => $admin->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review8 = Review::create([
            'text' => 'Очень неудобная система выставления счетов. Нет детализации, нельзя скачать акт в нормальном формате. Приходится каждый месяц писать менеджеру и ждать ответа неделю. Утомительно.',
            'rating' => 2,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review9 = Review::create([
            'text' => 'Забронировал переговорную, но приглашения коллегам не пришли. Пришлось вручную скидывать скриншот QR-кода. Система уведомлений работает через раз. На троечку с минусом.',
            'rating' => 2,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review10 = Review::create([
            'text' => 'Вроде всё есть, но всё кривое. Заявку на техобслуживание можно оставить, но нельзя указать срочность. Кондиционер чинили 3 дня, в офисе была сауна. Антиудобно.',
            'rating' => 2,
            'user_id' => $admin->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review11 = Review::create([
            'text' => 'Получил гостевой пропуск, но в нём не было отметки про парковку. Охранник не пропустил на парковку, пришлось искать место на улице. Мелочь, но бесит. Не продумано до конца.',
            'rating' => 2,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review12 = Review::create([
            'text' => 'Админ-панель для уведомлений — просто кошмар. Нельзя отредактировать отправленное сообщение, нельзя запланировать рассылку. Приходится делать всё вручную утром. Каменный век в цифровой обёртке.',
            'rating' => 2,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review13 = Review::create([
            'text' => 'История бронирований отображается только за месяц. Хотел посмотреть, сколько потратил в прошлом квартале — нереально. Отчётность никакая. Сервис как черновик, а не готовый продукт.',
            'rating' => 2,
            'user_id' => $admin->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review14 = Review::create([
            'text' => 'В целом, работает. QR-код открывает дверь, парковка бронируется. Но интерфейс приложения какой-то нелогичный, нужно привыкнуть. Дизайн унылый, но функционал базовый закрывает. На троечку.',
            'rating' => 3,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review15 = Review::create([
            'text' => 'Удобно, что все услуги в одном месте: пропуск, уборка, парковка. Но вот система напоминаний о продлении пропуска не работает. Пришлось ставить напоминалку в телефоне. Средненько.',
            'rating' => 3,
            'user_id' => $admin->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review16 = Review::create([
            'text' => 'Ни хорошо, ни плохо. Арендую офис, QR-код действует. Но когда сломался принтер, заявку на ремонт через приложение принимали сутки. В итоге вызвал своего мастера. Есть куда расти.',
            'rating' => 3,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review17 = Review::create([
            'text' => 'Пользуюсь, потому что заставил работодатель. Всё работает, но без удовольствия. Уведомления приходят с опозданием, карта в приложении тормозит. Сойдёт, если ничего лучше нет.',
            'rating' => 3,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review18 = Review::create([
            'text' => 'Цены адекватные, бронирование простое. Но вот подтверждение брони иногда приходит с задержкой в 10-15 минут. Нервничаешь, думаешь, прошло ли. В целом нормально, но есть нюансы.',
            'rating' => 3,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review19 = Review::create([
            'text' => 'Нравится, что можно быстро забронировать коворкинг на час. Не нравится, что нельзя посмотреть, кто ещё будет в этой зоне. Ощущение, будто сидишь в цифровой пустыне. Удовлетворительно.',
            'rating' => 3,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review20 = Review::create([
            'text' => 'Для базовых задач сойдёт. Заказал клининг, убрались. Но вот гибкости нет: нельзя указать "помыть окна" или "протереть жалюзи". Только стандартный набор. Три балла из пяти.',
            'rating' => 3,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review21 = Review::create([
            'text' => 'Очень удобный сервис! Всё в одном приложении: и пропуск, и парковка, и даже заказ кофе в переговорную можно оставить. Не хватает только интеграции с календарём, чтобы бронирования автоматически добавлялись. Но в целом — отлично!',
            'rating' => 4,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review22 = Review::create([
            'text' => 'Система заметно облегчила работу. Все заявки от арендаторов теперь в одном окне, не нужно бегать с бумажками. Минус один — иногда "подвисает" при большой нагрузке. Но команда техподдержки реагирует быстро. Спасибо!',
            'rating' => 4,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review23 = Review::create([
            'text' => 'Пользуюсь полгода. Стабильно, удобно, современно. Особенно радует, что QR-код обновляется сам и нельзя сделать скриншот — безопасность на уровне. Хотелось бы больше отчётов по расходу средств. Оценка: 4 с плюсом.',
            'rating' => 4,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review24 = Review::create([
            'text' => 'Нравится интерфейс — чистый и понятный. Карта БЦ с маршрутом — спасение для гостей. Заметила баг: при смене аватара картинка иногда "съезжает". Мелочь, но для дизайнера важно. В целом — здорово!',
            'rating' => 4,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review25 = Review::create([
            'text' => 'Как гость оцениваю на пять с минусом. Пропуск приходит быстро, на входе просто показал телефон — и всё. Единственное, иногда плохо ловит интернет в лифте, и код не грузится. Но это уже к оператору вопросы.',
            'rating' => 4,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review26 = Review::create([
            'text' => 'Упростила себе жизнь! Все пропуска для сотрудников и гостей теперь в системе, не нужно ничего распечатывать. Админка удобная. Не хватает массового создания пропусков для группы гостей. Но это уже придирки. Работает хорошо!',
            'rating' => 4,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review27 = Review::create([
            'text' => 'Бронирование парковки через приложение — это супер! Всегда знаю, что место будет. Цена адекватная. Хотелось бы видеть на схеме не только номер, но и тип места (у колонны, широкое). Но это уже люксовые пожелания. Спасибо!',
            'rating' => 4,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review28 = Review::create([
            'text' => 'Революция в управлении офисом! С момента внедрения "Рабочей точки" мы на 40% сократили время на администрирование пропусков и заявок. Сотрудники довольны, гости в восторге. Интеграция с 2ГИС — гениальное решение. Топовый сервис!',
            'rating' => 5,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review29 = Review::create([
            'text' => 'Идеально продуманный UX! Всё интуитивно, красиво, быстро. Уведомления приходят вовремя, QR-код работает без нареканий. Отдельный респект за антифрод-защиту. Это не просто сервис, это забота о пользователе. 10/10!',
            'rating' => 5,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review30 = Review::create([
            'text' => 'Наконец-то в нашем БЦ появился современный digital-сервис! Арендую несколько помещений, управлять всем через одну панель — невероятно удобно. Финансовая отчётность прозрачная, всё чеки приходят на почту. Вы молодцы! Побольше бы таких решений.',
            'rating' => 5,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review31 = Review::create([
            'text' => 'Часто организую мероприятия в переговорных вашего БЦ. "Рабочая точка" — это спасение! Легко забронировать, мгновенно разослать приглашения всем участникам, контролировать доступ. Всё работает как швейцарские часы. Безупречно!',
            'rating' => 5,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review32 = Review::create([
            'text' => 'Пользуюсь коворкингом 2-3 раза в неделю. Приложение стало моим лучшим помощником: вижу свободные места, бронирую за минуту, оплачиваю картой. Всё быстро, без лишних движений. Даже Wi-Fi быстрее подключается! Лучший сервис из всех, что видел.',
            'rating' => 5,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review33 = Review::create([
            'text' => 'Пишу как внутренний пользователь. Админ-панель — мечта! Все процессы автоматизированы, заявки не теряются, статистика под рукой. Жизнь стала проще, работа — эффективнее. Коллеги из других БЦ уже спрашивают, где мы такую систему взяли. Горжусь!',
            'rating' => 5,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);
        $review34 = Review::create([
            'text' => 'Был в десятках бизнес-центров по всему миру. Ваш сервис "Рабочая точка" — один из лучших в своём классе. Сочетание простоты, безопасности и инноваций впечатляет. Это не расходы, это инвестиция в репутацию и комфорт. Браво разработчикам!',
            'rating' => 5,
            'user_id' => $user->id,
            'created_at' => now()->addDays(5),
            'updated_at' => now()->addDays(5),
        ]);

    }
}
