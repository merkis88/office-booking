<?php

namespace App\Services\Qr;

use App\Models\Booking;
use Illuminate\Validation\ValidationException;

final class QrAccessValidator
{
    private int $beforeMinutes = 30;
    private int $afterMinutes = 15;

    public function assertCanIssue(Booking $booking): void
    {
        if ($booking->status !== 'active') {
            throw ValidationException::withMessages([
                'status' => ['QR доступен только для активных бронирований'],
            ]);
        }

        $now = now();
        $start = $booking->start_time;
        $end = $booking->end_time;

        $openFrom = $start->copy()->subMinutes($this->beforeMinutes);
        $closeAt = $end->copy()->addMinutes($this->afterMinutes);

        if ($now->lt($openFrom)) {
            throw ValidationException::withMessages([
                'time' => ['QR будет доступен ближе к началу бронирования'],
            ]);
        }

        if ($now->gt($closeAt)) {
            throw ValidationException::withMessages([
                'time' => ['QR уже недоступен. Время бронирования прошло'],
            ]);
        }
    }
}
