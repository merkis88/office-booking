<?php

namespace App\Handlers\Profile;

use App\Models\Booking;
use App\Models\Qr;
use App\Models\User;

final class GetProfileHandler
{
    public function handle(User $user): array
    {
        $booking = Booking::query()
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->where('pass_type', 'qr')
            ->where('end_time', '>=', now())
            ->orderBy('start_time')
            ->first();

        $qr = null;

        if ($booking) {
            $qr = Qr::query()
                ->where('booking_id', $booking->id)
                ->where('user_id', $user->id)
                ->first();
        }

        return [
            'id' => $user->id,
            'photo' => $user->photo,
            'first_name' => $user->first_name,
            'last_name' => $user->last_name,
            'patronymic' => $user->patronymic,
            'phone' => $user->phone,
            'email' => $user->email,
            'qr_hash' => $qr?->hash,
            'qr_booking' => $booking ? [
                'id' => $booking->id,
                'place_id' => $booking->place_id,
                'start_time' => $booking->start_time,
                'end_time' => $booking->end_time,
            ] : null,
            'created_at' => $user->created_at,
            'updated_at' => $user->updated_at,
        ];
    }
}
