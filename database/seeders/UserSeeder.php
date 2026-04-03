<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Role;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $roleAdmin = Role::create(['role_name' => 'admin']);
        $roleUser = Role::create(['role_name' => 'user']);

        User::create([
            'role_id' => $roleAdmin->id,
            'first_name' => 'Евгений',
            'last_name' => 'Конохов',
            'email' => 'admin@admin.com',
            'password' => Hash::make('password'),
            'photo' => 'profile-photos/мужик_4.jpg',
            'is_verified' => true,
            'email_verified_at' => now(),
        ]);

        User::create([
            'role_id' => $roleUser->id,
            'first_name' => 'Алексей',
            'last_name' => 'Краснов',
            'email' => 'user1@user.com',
            'password' => Hash::make('password'),
            'photo' => 'profile-photos/мужик_1.jpg',
            'is_verified' => true,
            'email_verified_at' => now(),
        ]);

        User::create([
            'role_id' => $roleUser->id,
            'first_name' => 'Марина',
            'last_name' => 'Цветаева',
            'email' => 'user2@user.com',
            'password' => Hash::make('password'),
            'photo' => 'profile-photos/женщина_1.jpg',
            'is_verified' => true,
            'email_verified_at' => now(),
        ]);

        User::create([
            'role_id' => $roleUser->id,
            'first_name' => 'Сергей',
            'last_name' => 'Петров',
            'email' => 'user3@user.com',
            'password' => Hash::make('password'),
            'photo' => 'profile-photos/мужик_2.jpg',
            'is_verified' => true,
            'email_verified_at' => now(),
        ]);

        User::create([
            'role_id' => $roleUser->id,
            'first_name' => 'Анатолий',
            'last_name' => 'Ноумов',
            'email' => 'user4@user.com',
            'password' => Hash::make('password'),
            'photo' => 'profile-photos/мужик_3.jpg',
            'is_verified' => true,
            'email_verified_at' => now(),
        ]);

        User::create([
            'role_id' => $roleUser->id,
            'first_name' => 'Екатерина',
            'last_name' => 'Трошенникова',
            'email' => 'user@user.com',
            'password' => Hash::make('password'),
            'photo' => 'profile-photos/женщина_8.jpg',
            'is_verified' => true,
            'email_verified_at' => now(),
        ]);
    }
}
