<?php

namespace App\Handlers\Bookings;

use App\Models\Booking;
use App\Models\User;
use App\Services\Bookings\BookingOverlapService;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

final class ExtendBookingHandler
{
    public function __construct(private readonly BookingOverlapService $overlap) {}

    public function handle(Booking $booking, User $actor, int $minutes): Booking
    {
        $this->assertCanExtend($booking, (int) $actor->id);

        if (!in_array($booking->status, ['pending', 'approved'], true)) {
            throw ValidationException::withMessages([
                'status' => ['Нельзя продлить бронирование в текущем статусе'],
            ]);
        }

        if ($minutes <= 0 || $minutes > 1440) {
            throw ValidationException::withMessages([
                'minutes' => ['Продление должно быть от 1 до 1440 минут'],
            ]);
        }

        $start = CarbonImmutable::parse($booking->start_time);
        $currentEnd = CarbonImmutable::parse($booking->end_time);

        if ($currentEnd->isPast()) {
            throw ValidationException::withMessages([
                'end_time' => ['Нельзя продлить бронирование, которое уже закончилось'],
            ]);
        }

        $newEnd = $currentEnd->addMinutes($minutes);

        return DB::transaction(function () use ($booking, $start, $newEnd) {
            $this->overlap->assertNoOverlap(
                placeId: (int) $booking->place_id,
                startTime: $start,
                endTime: $newEnd,
                ignoreBookingId: (int) $booking->id
            );

            $booking->end_time = $newEnd;
            $booking->save();

            $booking->load('place');

            return $booking;
        });
    }

    private function assertCanExtend(Booking $booking, int $actorId): void
    {
        $isOwner = $booking->user_id !== null && (int)$booking->user_id === $actorId;
        $isGuestCreator = $booking->user_id === null && (int)$booking->created_by === $actorId;

        if (!($isOwner || $isGuestCreator)) {
            abort(403, 'Нет доступа к бронированию');
        }
    }
}
