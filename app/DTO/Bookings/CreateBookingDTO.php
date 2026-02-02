<?php
namespace App\DTO\Bookings;

use Carbon\CarbonImmutable;

final class CreateBookingDTO
{
    public function __construct(
        public readonly int $placeId,
        public readonly CarbonImmutable $startTime,
        public readonly CarbonImmutable $endTime,
        public readonly ?int $userId,
        public readonly ?int $guestName,
        public readonly string $passType,
    )
    {

    }

}
