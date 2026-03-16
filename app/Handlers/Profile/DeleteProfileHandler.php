<?php

namespace App\Handlers\Profile;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

final class DeleteProfileHandler
{
    public function handle(User $user, string $password): void
    {
        if (!Hash::check($password, $user->password)) {
            throw ValidationException::withMessages([
                'password' => ['Неверный пароль'],
            ]);
        }

        DB::transaction(function () use ($user) {
            $user->tokens()->delete();

            $user->delete();
        });
    }
}
