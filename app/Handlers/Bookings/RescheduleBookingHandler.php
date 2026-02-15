<?php

namespace App\Handlers\Bookings;

use App\DTO\Bookings\RescheduleBookingDTO;
use App\Models\Booking;
use App\Models\User;
use App\Services\Bookings\BookingOverlapService;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

final class RescheduleBookingHandler
{
    public function __construct(private readonly BookingOverlapService $overlap) {}

    public function handle(RescheduleBookingDTO $dto, Booking $booking, User $user): Booking
    {
        $this->assertCanReschedule($booking, (int) $user->id);

        if ($dto->startTime->isPast()) {
            throw ValidationException::withMessages([
                'start_time' => ['Нельзя перенести бронирование в прошлое']
            ]);
        }

        if (!in_array($booking->status, ['pending', 'approved'], true)) {
            throw ValidationException::withMessages([
                'status' => ['Нельзя переносить бронирование в текущем статусе']
            ]);
        }

        return DB::transaction(function () use ($dto, $booking) {

            $this->overlap->assertNoOverlap(
                placeId: (int) $booking->place_id,
                startTime: $dto->startTime,
                endTime: $dto->endTime,
                ignoreBookingId: (int) $booking->id
            );

            if ($booking->status === 'approved') {
                $booking->status = 'pending';
            }

            $booking->start_time = $dto->startTime;
            $booking->end_time = $dto->endTime;
            $booking->save();

            $booking->load('place');

            return $booking;
        });
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
