<?php

namespace Database\Seeders;

use App\Models\Parking_place;
use App\Models\User;
use App\Models\Role;
use App\Models\Organization;
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
        $roleManager = Role::create(['role_name' => 'manager']);
        $roleUser = Role::create(['role_name' => 'user']);
        $org = Organization::create([
            'name' => 'Operating point',
        ]);

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
        ]);

        $place = Place::create([
            'organization_id' => $org->id,
            'name' => 'Meeting Room"',
            'type' => 'conference_room',
            'capacity' => 5,
            'number_place' => 48,
            'is_active' => true,
        ]);

        Service::create([
            'place_id' => $place->id,
            'date_service' => now()->addDays(5),
            'type_service' => 'cleaning',
            'comment' => 'Коммент',
        ]);

        $parking_place = Parking_place::create([
            'place_row' => 0,
            'status' => 'free'
        ]);

        $booking = Booking::create([
            'place_id' => $place->id,
            'created_by' => $user->id,
            'user_id' => $user->id,
            'organization_id' => $org->id,
            'price' => 1000,
            'start_time' => now()->addDay()->setHour(10)->setMinute(0),
            'end_time' => now()->addDay()->setHour(12)->setMinute(0),
            'status' => 'approved',
            'pass_type' => 'qr',
        ]);

        Qr::create([
            'booking_id' => $booking->id,
            'hash' => hash('sha256', 'unique_secret_string_' . $booking->id),
            'used_at' => null,
        ]);
    }
}
