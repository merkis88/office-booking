<?php

namespace App\Handlers\Profile;

use App\Handlers\Qr\CreateOrGetUserQrHandler;
use App\Models\Booking;
use App\Models\User;
use Illuminate\Validation\ValidationException;

final class GetProfileQrsHandler
{
    public function __construct(private readonly CreateOrGetUserQrHandler $qrHandler) {}

    public function handle(User $user): array
    {
        $bookings = Booking::query()
            ->where('user_id', $user->id)
            ->where('status', 'approved')
            ->orderBy('start_time')
            ->limit(50)
            ->get();

        $result = [];

        foreach ($bookings as $booking) {
            try {
                $qr = $this->qrHandler->handle($booking, $user);
            } catch (ValidationException $e) {
                continue;
            }

            $result[] = [
                'booking_id' => $booking->id,
                'place_id' => $booking->place_id,
                'start_time' => $booking->start_time,
                'end_time' => $booking->end_time,
                'hash' => $qr->hash,
                'time_window' => $qr->time_window,
            ];
        }

        return $result;
    }
}
