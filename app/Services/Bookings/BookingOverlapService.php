<?php

namespace App\Services\Bookings;

use App\Models\Booking;
use Carbon\CarbonImmutable;
use Illuminate\Validation\ValidationException;

final class BookingOverlapService
{
    public function assertNoOverlap(int $placeId, CarbonImmutable $startTime, CarbonImmutable $endTime, ?int $ignoreBookingId = null): void
    {
        $query = Booking::query()
            ->where('place_id', $placeId)
            ->whereIn('status', ['pending', 'approved'])
            ->where('start_time', '<', $endTime)
            ->where('end_time', '>', $startTime);

        if ($ignoreBookingId !== null) {
            $query->where('id', '!=', $ignoreBookingId);
        }

        if ($query->exists()) {
            throw ValidationException::withMessages([
                'time' => ['В это время помещение уже забронировано'],
            ]);
        }
    }
}
