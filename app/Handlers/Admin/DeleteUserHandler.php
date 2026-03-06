<?php

namespace App\Handlers\Admin;

use App\Models\Booking;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Storage;

final class DeleteUserHandler
{
    public function handler(User $target, User $user): User
    {
        if ($target->id === $user->id) {
            throw ValidationException::withMessages([
                'user' => ['Нельзя удалить самого себя']
            ]);
        }

        $hasActiveBooking = Booking::query()
            ->where('user_id', $target->id)
            ->where('status', 'active')
            ->exists();

        if ($hasActiveBooking) {
            throw ValidationException::withMessages([
                'user' => ['Нельзя удалить пользователя с активными бронями']
            ]);
        }

        $hasRelatedBooking = Booking::query()
            ->where('user_id', $target->id)
            ->where('created_by', $target->id)
            ->exists();

        if ($hasRelatedBooking) {
            throw ValidationException::withMessages([
               'user' => ['Нельзя удалить пользователя, связанно с бронированием']
            ]);
        }

        DB::transaction(function () use ($target) {
            $target->delete();
        });

        return $target;
    }

}
