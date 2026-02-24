<?php

namespace App\Handlers\Qr;

use App\Models\Booking;
use App\Models\Qr;
use App\Models\User;
use App\Services\Qr\QrHashService;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

final class CreateUserQrHandler
{
    public function __construct(private readonly QrHashService $hashService) {}

    private int $windowSeconds = 1800;
    private int $beforeMinutes = 30;
    private int $afterMinutes  = 15;

    public function handle(Booking $booking, User $user, ?int $timeWindow = null): Qr
    {
        $this->assertQrAllowed($booking);
        $this->assertCanUseBooking($booking, $user);

        $window = $timeWindow ?? $this->currentWindow();

        $existing = Qr::query()
            ->where('booking_id', $booking->id)
            ->where('time_window', $window)
            ->where('user_id', $user->id)
            ->first();

        if ($existing) {
            return $existing;
        }

        return DB::transaction(function () use ($booking, $user, $window) {

            $existing = Qr::query()
                ->where('booking_id', $booking->id)
                ->where('time_window', $window)
                ->where('user_id', $user->id)
                ->lockForUpdate()
                ->first();

            if ($existing) {
                return $existing;
            }

            $hash = $this->hashService->makeForUser($booking, $window, (int) $user->id);

            return Qr::query()->create([
                'booking_id' => $booking->id,
                'time_window' => $window,
                'user_id' => $user->id,
                'recipient_email' => null,
                'hash' => $hash,
                'used_at' => null,
            ]);
        });
    }

    private function currentWindow(): int
    {
        return intdiv(now()->timestamp, $this->windowSeconds);
    }

    private function assertCanUseBooking(Booking $booking, User $user): void
    {
        $isOwner = $booking->user_id !== null && (int)$booking->user_id === (int)$user->id;
        $isCreator = (int)$booking->created_by === (int)$user->id;

        if (!($isOwner || $isCreator)) {
            abort(403, 'Нет доступа к этому бронированию');
        }
    }

    private function assertQrAllowed(Booking $booking): void
    {
        if ($booking->status !== 'active') {
            throw ValidationException::withMessages([
                'status' => ['QR доступен только для активных бронирований'],
            ]);
        }

        $now = now();
        $start = $booking->start_time;
        $end   = $booking->end_time;

        $openFrom = $start->copy()->subMinutes($this->beforeMinutes);
        $closeAt  = $end->copy()->addMinutes($this->afterMinutes);

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
