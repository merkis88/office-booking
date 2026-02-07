<?php

namespace App\Handlers\Bookings;

use App\DTO\Bookings\CreateBookingDTO;
use App\Models\Booking;
use App\Models\PlaceManager;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use App\Models\User;

final class CreateGuestBookingHandler
{
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
            $isOverlap = Booking::query()
                ->where('place_id', $dto->placeId)
                ->whereIn('status', ['pending', 'approved'])
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
               'created_by' => $actor->id,
               'guest_name' => $dto->guestName,
               'user_id' => null,
               'start_time' => $dto->startTime,
               'end_time' => $dto->endTime,
               'status' => 'pending',
               'pass_type' => $dto->passType,
            ]);
        });
    }

}
