<?php

namespace App\Services\Bookings;

use App\Models\Place;
use Carbon\CarbonInterface;
use Illuminate\Validation\ValidationException;

final class BookingPriceService
{
    public function calculate(Place $place, CarbonInterface $start, CarbonInterface $end)
    {
        if ($end->lessThanOrEqualTo($start)) {
            throw ValidationException::withMessages([
                'time' => ['Некорректный интервал бронирования']
            ]);
        }

        $pricePerHour = $place->price;
        $minutes = $start->diffInMinutes($end);
        $total = ($pricePerHour / 60) * $minutes;

        return number_format($total, 2, '.', '');
    }
}
