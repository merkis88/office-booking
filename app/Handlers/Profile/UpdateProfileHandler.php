<?php

namespace App\Handlers\Profile;

use App\Models\User;

final class UpdateProfileHandler
{
    public function handle(User $user, array $data): array
    {
        if (array_key_exists('first_name', $data)) {
            $user->first_name = $data['first_name'];
        }

        if (array_key_exists('last_name', $data)) {
            $user->last_name = $data['last_name'];
        }

        if (array_key_exists('patronymic', $data)) {
            $user->patronymic = $data['patronymic'];
        }

        if (array_key_exists('phone', $data)) {
            $user->phone = $data['phone'];
        }

        if (array_key_exists('email', $data)) {
            $user->email = $data['email'];
        }

        $user->save();

        return [
            'id' => $user->id,
            'role_id' => $user->role_id,
            'first_name' => $user->first_name,
            'last_name' => $user->last_name,
            'patronymic' => $user->patronymic,
            'phone' => $user->phone,
            'email' => $user->email,
            'created_at' => $user->created_at,
            'updated_at' => $user->updated_at,
        ];
    }
}
