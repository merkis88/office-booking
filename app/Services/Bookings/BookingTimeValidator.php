<?php

namespace App\Services\Bookings;

use Carbon\CarbonImmutable;
use Illuminate\Validation\ValidationException;

final class BookingTimeValidator
{
    public function validate(CarbonImmutable $startTime, CarbonImmutable $endTime): void
    {
        $now = CarbonImmutable::now();

        if ($endTime->lessThanOrEqualTo($startTime)) {
            throw ValidationException::withMessages([
                'end_time' => ['Время окончания должно быть позже времени начала'],
            ]);
        }

        if ($startTime->lessThanOrEqualTo($now)) {
            throw ValidationException::withMessages([
                'start_time' => ['Нельзя создать бронирование на прошедшее время'],
            ]);
        }
    }
}
