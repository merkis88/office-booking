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

        if ($booking->status === 'rejected') {
            throw ValidationException::withMessages([
                'status' => ['Бронирование уже отменено']
            ]);
        }

        if (!in_array($booking->status, ['pending', 'approved'], true)) {
            throw ValidationException::withMessages([
                'status' => ['Нельзя отменить заявку в текущем статусе']
            ]);
        }

        $start_time = CarbonImmutable::parse($booking->start_time);
        if ($start_time->isPast()) {
            throw ValidationException::withMessages([
               'start_time' => ['Нельзя отменить бронирование которе уже началось']
            ]);
        }

        $booking->status = 'rejected';
        $booking->save();

        $booking->load('place');

        return $booking;
    }

    private function assertCanView(Booking $booking, int $actorId): void
    {
        $isOwner = $booking->user_id !== null && (int)$booking->user_id === $actorId;
        $isGuestCreator = $booking->user_id === null && (int)$booking->created_by === $actorId;

        if (!($isOwner || $isGuestCreator)) {
            abort(403, 'Нет доступа к бронированию');
        }
    }
}
