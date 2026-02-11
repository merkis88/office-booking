<?php

namespace App\Services\Qr;

use App\Models\Booking;

final class QrHashService
{
    /**
     * Генерация персонального hash для QR
     */

    public function makeForUser(Booking $booking, int $timeWindow, int $userId): string
    {
        $recipient = 'user:' . $userId;
        return $this->make($booking, $timeWindow, $recipient);
    }

    public function makeForGuest(Booking $booking, int $timeWindow, string $email): string
    {
        $recipient = 'guest:' . $email;
        return $this->make($booking, $timeWindow, $recipient);
    }

    private function make(Booking $booking, int $timeWindow, string $recipient): string
    {
        $payload = implode('|', [
            'booking_id=' . $booking->id,
            'place_id=' . $booking->place_id,
            'start=' . (string) $booking->start_time,
            'end=' . (string) $booking->end_time,
            'window=' . $timeWindow,
            'recipient=' . $recipient,
        ]);

        $key = $this->getAppKeyBytes();

        return hash_hmac('sha256', $payload, $key);
    }

    private function getAppKeyBytes(): string
    {
        $key = (string) config('app.key');

        if (str_starts_with($key, 'base64:')) {
            $decoded = base64_decode(substr($key, 7), true);
            if ($decoded !== false) {
                return $decoded;
            }
        }

        return $key;
    }
}
