<?php

namespace App\Handlers\Admin;

use App\Models\User;
use Illuminate\Validation\ValidationException;

final class UnblockUserHandler
{
    public function handle(string $email, User $admin): User
    {
        $target = User::query()
            ->where('email', $email)
            ->first();

        if (!$target) {
            throw ValidationException::withMessages([
                'email' => ['Пользователь с таким email не найден'],
            ]);
        }

        if ($target->id === $admin->id) {
            throw ValidationException::withMessages([
                'email' => ['Нельзя разблокировать самого себя этим методом'],
            ]);
        }

        if (!$target->is_blocked) {
            throw ValidationException::withMessages([
                'email' => ['Пользователь не заблокирован'],
            ]);
        }

        $target->is_blocked = false;
        $target->save();

        return $target;

    }
}
