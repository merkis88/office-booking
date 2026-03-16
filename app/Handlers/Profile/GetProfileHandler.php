<?php

namespace App\Handlers\Profile;

use App\Models\User;

final class GetProfileHandler
{
    public function handle(User $user): array
    {
        return [
            'id' => $user->id,
            'photo' => $user->photo,
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
