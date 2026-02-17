<?php

namespace App\Handlers\Bookings;

use App\Models\Booking;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Validation\ValidationException;

final class CancelBookingHandler
{
    public function handle(Booking $booking, User $user): Booking
    {
        $this->assertCanView($booking, (int) $user->id);

        if ($booking->status === 'cancelled') {
            throw ValidationException::withMessages([
                'status' => ['Бронирование уже отменено'],
            ]);
        }

        if ($booking->status !== 'active') {
            throw ValidationException::withMessages([
                'status' => ['Нельзя отменить бронирование в текущем статусе'],
            ]);
        }

        $startTime = CarbonImmutable::parse($booking->start_time);
        if ($startTime->isPast()) {
            throw ValidationException::withMessages([
                'start_time' => ['Нельзя отменить бронирование, которое уже началось'],
            ]);
        }

        $booking->status = 'cancelled';
        $booking->save();

        $booking->load('place');

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
