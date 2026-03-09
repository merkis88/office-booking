<?php

namespace App\Handlers\Bookings;

use App\DTO\Bookings\CreateBookingDTO;
use App\Models\Booking;
use App\Models\User;
use App\Services\Bookings\BookingOverlapService;
use Illuminate\Support\Facades\DB;
use App\Services\Bookings\BookingBusinessHoursService;

final class CreateBookingHandler
{
    public function __construct(private readonly BookingOverlapService $overlap, private readonly BookingBusinessHoursService $hours) {}
    public function handle(CreateBookingDTO $dto, User $actor): Booking
    {
        $guestName = $dto->guestName;
        $userId = $guestName ? null : (int) $actor->id;

        $this->hours->assertWithinBusinessHours($dto->startTime, $dto->endTime);

        return DB::transaction(function () use ($dto, $actor, $userId, $guestName) {
            $this->overlap->assertNoOverlap(
                placeId: $dto->placeId,
                startTime: $dto->startTime,
                endTime: $dto->endTime
            );

            $booking = Booking::query()->create([
                'place_id' => $dto->placeId,
                'created_by' => $actor->id,
                'user_id' => $userId,
                'guest_name' => $guestName,
                'start_time' => $dto->startTime,
                'end_time' => $dto->endTime,
                'status' => 'pending',
                'pass_type' => $dto->passType,
            ]);

            $booking->load('place', 'user', 'creator');

            return $booking;
        });
    }
}
