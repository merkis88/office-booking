<?php

namespace App\DTO\Bookings;

use Carbon\CarbonImmutable;

final class RescheduleBookingDTO
{
    public function __construct(
        public readonly CarbonImmutable $startTime,
        public readonly CarbonImmutable $endTime,
    ) {}
}
