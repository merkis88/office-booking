<?php

namespace App\Handlers\Bookings;

use App\Models\Booking;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB;
use App\Models\PlaceManager;

class AdminApproveBookingHandler
{
    public function handle(Booking $booking): Booking
    {
        if ($booking->status !== 'pending') {
            throw ValidationException::withMessages([
               'status' => ['Подтвердить можно только бронирование со статусом: в ожидании']
            ]);
        }

        DB::transaction(function () use ($booking) {
            $booking->status = 'approved';
            $booking->save();

            if (!is_null($booking->user_id)) {
                PlaceManager::firstOrCreate([
                    'place_id' => $booking->place_id,
                    'user_id'  => $booking->user_id,
                ],
                [
                    'created_from_booking_id' => $booking->id
                ]
                );
            }
        });

        $booking->load('place', 'user', 'creator');

        return $booking;

    }
}
