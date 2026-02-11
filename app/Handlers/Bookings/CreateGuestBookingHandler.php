<?php

namespace App\Handlers\Bookings;

use App\DTO\Bookings\CreateBookingDTO;
use App\Models\Booking;
use App\Models\PlaceManager;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use App\Models\User;
use App\Services\Bookings\BookingOverlapService;

final class CreateGuestBookingHandler
{
    public function __construct(private readonly BookingOverlapService $overlap) {}

    public function handle(CreateBookingDTO $dto, User $actor)
    {
        if(empty($dto->guestName)) {
            throw ValidationException::withMessages([
               'guest_name' => ['guest_name обязателен для гостевой брони'],
            ]);
        }

        $isPlaceManager = PlaceManager::query()
            ->where('place_id', $dto->placeId)
            ->where('user_id', $actor->id)
            ->exists();

        if (!$isPlaceManager) {
            abort(403, 'У вас нет прав пригласить гостей в это помещение');
        }

        return DB::transaction(function () use ($dto, $actor) {
            $this->overlap->assertNoOverlap(
                placeId: $dto->placeId,
                startTime: $dto->startTime,
                endTime: $dto->endTime
            );

            $booking = Booking::query()->create([
                'place_id' => $dto->placeId,
                'created_by' => $actor->id,
                'user_id' => null,
                'guest_name' => $dto->guestName,
                'start_time' => $dto->startTime,
                'end_time' => $dto->endTime,
                'status' => 'pending',
                'pass_type' => $dto->passType,
            ]);

            $booking->load('place', 'creator');

            return $booking;
        });
    }
}
