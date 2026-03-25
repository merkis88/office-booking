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
        public readonly ?CarbonImmutable $from,
        public readonly ?CarbonImmutable $to,
        public readonly string $sortDirection,
        public readonly int $perPage,
    ) {}


}
