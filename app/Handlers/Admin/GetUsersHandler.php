<?php

namespace App\Handlers\Admin;

use App\Models\User;
use Illuminate\Support\Facades\Storage;

final class GetUsersHandler
{
    public function handle(): array
    {
        return User::query()
            ->latest('id')
            ->get()
            ->map(function (User $user): array {
                return [
                    'id' => $user->id,
                    'photo' => $user->photo,
                    'photo_url' => $user->photo ? Storage::disk('public')->url($user->photo) : null,
                    'first_name' => $user->first_name,
                    'last_name' => $user->last_name,
                    'patronymic' => $user->patronymic,
                    'phone' => $user->phone,
                    'email' => $user->email,
                    'is_blocked' => $user->is_blocked,
                    'created_at' => $user->created_at,
                    'updated_at' => $user->updated_at,
                ];
            })
            ->values()
            ->all();
    }
}
