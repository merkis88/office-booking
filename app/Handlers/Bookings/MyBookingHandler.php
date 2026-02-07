<?php

namespace App\Handlers\Bookings;

use App\DTO\Bookings\MyBookingsDTO;
use App\Models\Booking;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

final class MyBookingHandler
{
    public function handle(User $user, MyBookingsDTO $dto): LengthAwarePaginator
    {
        $query = Booking::query()
            ->with('place')
            ->where('user_id', $user->id);

        if ($dto->status !== null) {
            $query->where('status', $dto->status);
        }

        if ($dto->placeId !== null) {
            $query->where('place_id', $dto->placeId);
        }

        if ($dto->from !== null) {
            $query->where('start_time', '>=', $dto->from);
        }

        if ($dto->to !== null) {
            $query->where('start_time', '<=', $dto->to);
        }

        $query->orderBy('start_time', $dto->sortDirection);

        return $query->paginate($dto->perPage);
    }
}
