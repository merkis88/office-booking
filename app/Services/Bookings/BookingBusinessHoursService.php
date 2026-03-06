<?php

namespace App\Services\Bookings;

use Carbon\CarbonImmutable;
use Illuminate\Validation\ValidationException;

final class BookingBusinessHoursService
{
    public function assertWithinBusinessHours(CarbonImmutable $start, CarbonImmutable $end): void
    {
        $tz = (string) config('bookings.timezone', 'UTC');
        $openHour = (int) config('bookings.open_hour');
        $closeHour = (int) config('bookings.close_hour');

        $startLocal = $start->setTimezone($tz);
        $endLocal = $end->setTimezone($tz);

        if ($end->lessThanOrEqualTo($startLocal)) {
            throw ValidationException::withMessages([
                'time' => ['Некорректный интервал бронирования'],
            ]);
        }

        $startOpenFrom = $startLocal->startOfDay()->setTime($openHour, 0);
        $startCloseAt  = $startLocal->startOfDay()->setTime($closeHour, 0);

        $endOpenFrom = $endLocal->startOfDay()->setTime($openHour, 0);
        $endCloseAt  = $endLocal->startOfDay()->setTime($closeHour, 0);

        if ($start->lt($startOpenFrom) || $start->gt($startCloseAt)) {
            throw ValidationException::withMessages([
                'time' => ['БЦ работает с 09:00 до 22:00'],
            ]);
        }

        if ($end->lt($endOpenFrom) || $end->gt($endCloseAt)) {
            throw ValidationException::withMessages([
                'time' => ['БЦ работает с 09:00 до 22:00'],
            ]);
        }
    }
}
