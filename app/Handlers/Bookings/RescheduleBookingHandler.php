<?php

namespace App\Handlers\Bookings;

use App\DTO\Bookings\RescheduleBookingDTO;
use App\Models\Booking;
use Illuminate\Validation\ValidationException;
use App\Models\User;

final class RescheduleBookingHandler
{
    public function handle(RescheduleBookingDTO $dto, Booking $booking, User $user): Booking
    {
        $this->assertCanReschedule($booking, (int) $user->id);

        if ($booking->status === 'cancelled') {
            throw ValidationException::withMessages([
               'status' => ['Нельзя переносить отменённое бронирование']
            ]);
        }

        if ($dto->startTime->isPast()) {
            throw ValidationException::withMessages([
                'start_time' => ['Нельзя перенести бронирование в прошлое']
            ]);
        }

        $isOverlap = Booking::query()
            ->where('place_id', $booking->place_id)
            ->whereIn('status', ['pending', 'approved'])
            ->where('id', '!=', $booking->id)
            ->where('start_time', '<', $dto->endTime)
            ->where('end_time', '>', $dto->startTime)
            ->exists();

        if ($isOverlap) {
            throw ValidationException::withMessages([
                'time' => ['В это время помещение уже забронировано'],
            ]);
        }

        if ($booking->status === 'approved') {
            $booking->status = 'pending';
        }

        $booking->start_time = $dto->startTime;
        $booking->end_time = $dto->endTime;
        $booking->save();

        $booking->load('place');

        return $booking;
    }

    private function assertCanReschedule(Booking $booking, int $actorId): void
    {
        $isOwner = $booking->user_id !== null && (int)$booking->user_id === $actorId;
        $isGuestCreator = $booking->user_id === null && (int)$booking->created_by === $actorId;

        if (!($isOwner || $isGuestCreator)) {
            abort(403, 'Нет доступа к бронированию');
        }

    }
}
