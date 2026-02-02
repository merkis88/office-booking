<?php

namespace App\Handlers\Bookings;

use App\DTO\Bookings\CreateBookingDTO;
use App\Models\Booking;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

final class CreateBookingHandler
{
    public function handle(CreateBookingDTO $dto, User $user): Booking
    {
        $userId = $dto->userId ?? $user->id;
        $guestName = $dto->guestName;

        if (!empty($guestName)) {
            $userId = null;
        }

        return DB::transaction(function () use ($dto, $user, $userId, $guestName) {
            $isOverlap = Booking::query()
                ->where('place_id', $dto->placeId)
                ->where('status', ['pending', 'approved'])
                ->where('start_time', '<', $dto->endTime)
                ->where('end_time', '>', $dto->startTime)
                ->exists();

            if ($isOverlap) {
                throw ValidationException::withMessages([
                    'time' => ['В это время помещение уже забронировано']
                ]);
            }

            return Booking::query()->create([
                'place_id' => $dto->placeId,
                'created_by' => $user->id,
                'organization_id' => null,
                'user_id' => $dto->userId,
                'guest_name' => $guestName,
                'start_time' => $dto->startTime,
                'end_time' => $dto->endTime,
                'status' => 'pending',
                'pass_type' => $dto->passType,
            ]);
        });
    }
}
