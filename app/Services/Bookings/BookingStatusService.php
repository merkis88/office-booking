<?php

namespace App\Services\Bookings;

use App\Models\Booking;
use App\Models\User;

final class BookingStatusService
{
    public function syncUserExpiredBookings(User $user): void
    {
        $tz = config('booking.timezone');
        $now = now($tz);

        Booking::query()
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->get()
            ->each(function (Booking $booking) use ($now, $tz) {
                if ($booking->end_time->copy()->setTimezone($tz)->lessThanOrEqualTo($now)) {
                    $booking->status = 'over';
                    $booking->save();
                }
            });
    }
}
