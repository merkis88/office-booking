<?php

namespace App\Services\Bookings;

use Carbon\CarbonImmutable;
use Illuminate\Validation\ValidationException;

final class BookingBusinessHoursService
{
    public function assertWithinBusinessHours(CarbonImmutable $start, CarbonImmutable $end): void
    {
        $tz = (string) config('bookings.timezone', 'UTC');
        $openHour = (int) config('bookings.open_hour', 9);
        $closeHour = (int) config('bookings.close_hour', 22);

        $startLocal = $start->setTimezone($tz);
        $endLocal = $end->setTimezone($tz);

        if ($endLocal->lessThanOrEqualTo($startLocal)) {
            throw ValidationException::withMessages([
                'time' => ['Некорректный интервал бронирования'],
            ]);
        }

        $startOpenFrom = $startLocal->startOfDay()->setTime($openHour, 0);
        $startCloseAt  = $startLocal->startOfDay()->setTime($closeHour, 0);

        $endOpenFrom = $endLocal->startOfDay()->setTime($openHour, 0);
        $endCloseAt  = $endLocal->startOfDay()->setTime($closeHour, 0);

        if ($startLocal->lt($startOpenFrom) || $startLocal->gte($startCloseAt)) {
            throw ValidationException::withMessages([
                'time' => ["БЦ работает с {$openHour}:00 до {$closeHour}:00"],
            ]);
        }

        if ($endLocal->lte($endOpenFrom) || $endLocal->gt($endCloseAt)) {
            throw ValidationException::withMessages([
                'time' => ["БЦ работает с {$openHour}:00 до {$closeHour}:00"],
            ]);
        }
    }
}
