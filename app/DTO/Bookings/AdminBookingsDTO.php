<?php

namespace App\DTO\Bookings;

use Carbon\CarbonImmutable;

final class AdminBookingsDTO
{
    public function __construct(
        public readonly ?string $status,
        public readonly ?int $placeId,
        public readonly ?int $userId,
        public readonly ?int $createdBy,
        public readonly ?CarbonImmutable $from, // start_time >= from
        public readonly ?CarbonImmutable $to,   // start_time <= to
        public readonly string $sortDirection,  // asc|desc
        public readonly int $perPage,
    ) {}


}
