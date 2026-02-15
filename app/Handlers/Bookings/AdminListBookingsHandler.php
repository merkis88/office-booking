<?php

namespace App\Handlers\Bookings;

use App\DTO\Bookings\AdminBookingsDTO;
use App\Models\Booking;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;

final class AdminListBookingsHandler
{
    public function handle(AdminBookingsDTO $dto): LengthAwarePaginator
    {
        return $this->buildQuery($dto)->paginate($dto->perPage);
    }

    public function buildQuery(AdminBookingsDTO $dto): Builder
    {
        $query = Booking::query()->with(['place', 'user', 'creator']);

        if ($dto->status !== null) {
            $query->where('status', $dto->status);
        }

        if ($dto->userId !== null) {
            $query->where('user_id', $dto->userId);
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

        return $query;
    }

}
