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
            'is_verified' => false,
        ]);

        $place = Place::create([
            'name' => 'Meeting Room"',
            'photo' => 'places/1771145751_69918a17e552a.png',
            'type' => 'office',
            'capacity' => 5,
            'number_place' => 48,
            'price' => 4000.00,
            'description' => 'Комната для переговоров с проектором и маркерной доской',
            'is_active' => true,
        ]);


        $parking_place = Parking_place::create([
            'place_row' => 0,
            'status' => 'free'
        ]);

        $booking = Booking::create([
            'place_id' => $place->id,
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
            'place_id' => $place->id,
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
    }
}
