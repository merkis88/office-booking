<?php

namespace App\Handlers\Admin;

use App\DTO\Admin\BlockUserDTO;
use App\Models\User;
use App\Models\UserBlock;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

final class BlockUserHandler
{
    public function handle(BlockUserDTO $dto, User $admin): User
    {
        $target = User::query()
            ->where('email', $dto->email)
            ->first();

        if (!$target) {
            throw ValidationException::withMessages([
               'email' => ['Пользователь с таким email не найден']
            ]);
        }

        if ($target->id === $admin->id) {
            throw ValidationException::withMessages([
                'email' => ['Нельзя заблокировать самого себя']
            ]);
        }

        if ($target->is_blocked) {
            throw ValidationException::withMessages([
                'email' => ['Пользователь уже заблокирован'],
            ]);
        }

        $target->is_blocked = true;
        $target->save();

        return $target;

    }

}
