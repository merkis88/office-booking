<?php

namespace App\Handlers\Bookings;

use App\Models\Booking;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

final class MyBookingHandler
{
    public function handle(User $user): Collection
    {
        return Booking::query()
            ->with('place')
            ->where('user_id', $user->id)
            ->orderByDesc('start_time')
            ->get();
    }
}
