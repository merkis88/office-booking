<?php

namespace App\Handlers\Bookings;

use App\DTO\Bookings\AdminBookingsDTO;
use App\Models\Booking;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

final class AdminListBookingsHandler
{
    public function handle(AdminBookingsDTO $dto): LengthAwarePaginator
    {
        $query = Booking::query()->with(['place', 'user', 'creator']);

        if ($dto->status !== null) {
            $query->where('status', $dto->status);
        }

        if ($dto->placeId !== null) {
            $query->where('place_id', $dto->placeId);
        }

        if ($dto->createdBy !== null) {
            $query->where('created_by', $dto->createdBy);
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
