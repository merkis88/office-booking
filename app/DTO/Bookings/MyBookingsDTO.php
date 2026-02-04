<?php

namespace App\DTO\Bookings;

use Carbon\CarbonImmutable;

final class MyBookingsDTO
{
    public function __construct(
        public readonly ?string $status,
        public readonly ?int $placeId,
        public readonly ?CarbonImmutable $from,
        public readonly ?CarbonImmutable $to,
        public readonly string $sortDirection, // asc|desc
        public readonly int $perPage,
    ) {}
}
