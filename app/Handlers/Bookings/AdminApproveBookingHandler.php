<?php

namespace App\Handlers\Bookings;

use App\Models\Booking;
use Illuminate\Validation\ValidationException;

class AdminApproveBookingHandler
{
    public function handle(Booking $booking): Booking
    {
        if ($booking->status === 'rejected') {
            throw ValidationException::withMessages([
               'status' => ['Нельзя подтвердить отклонённое бронирование']
            ]);
        }

        if ($booking->status === 'approved') {
            throw ValidationException::withMessages([
               'status' => ['Бронирование уже подтверждено']
            ]);
        }

        if ($booking->status !== 'pending') {
            throw ValidationException::withMessages([
                'status' => ['В ожидании подвтреждения']
            ]);
        }

        $booking->status = 'approved';
        $booking->save();

        $booking->load('place', 'user', 'creator');

        return $booking;
    }
}
