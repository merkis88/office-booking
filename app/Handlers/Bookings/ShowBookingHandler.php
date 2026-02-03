<?php

namespace App\Handlers\Bookings;

use App\Models\Booking;
use App\Models\User;

final class ShowBookingHandler
{
    public function handle(Booking $booking, User $user): Booking
    {
        $booking->load('place');

        $this->assertCanView($booking, (int) $user->id);

        return $booking;
    }

    private function assertCanView(Booking $booking, int $actorId): void
    {
        $isOwner = $booking->user_id !== null && (int) $booking->user_id === $actorId;
        $isGuestCreator = $booking->user_id === null && (int) $booking->created_by === $actorId;

        if (!($isOwner || $isGuestCreator)) {
            abort(403, 'Нет доступа к бронированию');
        }
    }
}
