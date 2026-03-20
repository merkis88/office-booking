<?php

namespace App\Services\Qr;

use App\Models\Booking;

final class QrAvailabilityService
{
    private int $beforeMinutes = 30;
    private int $afterMinutes = 15;

    public function getAvailability(Booking $booking): array
    {
        $tz = (string) config('booking.timezone', 'UTC');

        $now =  now($tz);

        $start = $booking->start_time->copy()->setTimezone($tz);
        $end = $booking->end_time->copy()->setTimezone($tz);

        $availableFrom = $start->copy()->subMinutes($this->beforeMinutes);
        $availableUntil = $end->copy()->addMinutes($this->afterMinutes);

        if ($booking->status !== 'active') {
            return [
                'qr_visible' => false,
                'qr_message' => 'QR недоступен для неактивного бронирования',
                'qr_available_from' => $availableFrom->toIso8601String(),
                'qr_available_until' => $availableUntil->toIso8601String(),
            ];
        }

        if ($now->lt($availableFrom)) {
            return [
                'qr_visible' => false,
                'qr_message' => 'QR будет доступен ближе ко времени бронирования',
                'qr_available_from' => $availableFrom->toIso8601String(),
                'qr_available_until' => $availableUntil->toIso8601String(),
            ];
        }

        if ($now->gt($availableUntil)) {
            return [
                'qr_visible' => false,
                'qr_message' => 'QR уже недоступен. Время бронирования прошло',
                'qr_available_from' => $availableFrom->toIso8601String(),
                'qr_available_until' => $availableUntil->toIso8601String(),
            ];
        }

        return [
            'qr_visible' => true,
            'qr_message' => null,
            'qr_available_from' => $availableFrom->toIso8601String(),
            'qr_available_until' => $availableUntil->toIso8601String(),
        ];
    }
}
