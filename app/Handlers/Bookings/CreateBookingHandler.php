<?php

namespace App\Handlers\Bookings;

use App\DTO\Bookings\CreateBookingDTO;
use App\Handlers\Qr\CreateUserQrHandler;
use App\Models\Booking;
use App\Models\Place;
use App\Models\User;
use App\Services\Bookings\BookingBusinessHoursService;
use App\Services\Bookings\BookingOverlapService;
use Illuminate\Support\Facades\DB;
use App\Services\Bookings\BookingPriceService;
use App\Services\Bookings\BookingTimeValidator;

final class CreateBookingHandler
{
    public function __construct(
        private readonly BookingOverlapService $overlap,
        private readonly BookingBusinessHoursService $hours,
        private readonly CreateUserQrHandler $qrHandler,
        private readonly BookingPriceService $price,
        private readonly BookingTimeValidator $timeValidator
    ) {}

    public function handle(CreateBookingDTO $dto, User $user): Booking
    {
        $this->hours->assertWithinBusinessHours($dto->startTime, $dto->endTime);
        $this->timeValidator->validate($dto->startTime, $dto->endTime);

        return DB::transaction(function () use ($dto, $user) {
            $this->overlap->assertNoOverlap(
                placeId: $dto->placeId,
                startTime: $dto->startTime,
                endTime: $dto->endTime
            );

            $place = Place::query()->findOrFail($dto->placeId);

            $price = $this->price->calculate($place, $dto->startTime, $dto->endTime);

            $booking = Booking::query()->create([
                'place_id' => $dto->placeId,
                'user_id' => $user->id,
                'created_by' => $user->id,
                'start_time' => $dto->startTime,
                'end_time' => $dto->endTime,
                'status' => 'active',
                'pass_type' => $dto->passType,
                'price' => $price,
            ]);

            if ($dto->passType === 'qr') {
                $this->qrHandler->createForSelf($booking, $user);
            }

            return $booking->load('place', 'user', 'creator', 'qrs');
        });
    }
}
