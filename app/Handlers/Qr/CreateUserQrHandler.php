<?php

namespace App\Handlers\Qr;

use App\Models\Booking;
use App\Models\Qr;
use App\Models\User;
use App\Services\Qr\QrHashService;
use App\Services\Qr\QrWindowService;
use Illuminate\Support\Facades\DB;

final class CreateUserQrHandler
{
    public function __construct(private readonly QrHashService $hashService, private readonly QrWindowService $windowService) {}

    public function handle(Booking $booking, User $user, ?int $timeWindow = null): Qr {
        $this->assertCanUseBooking($booking, $user);

        $window = $timeWindow ?? $this->windowService->current();

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

            $hash = $this->hashService->makeForUser(
                booking: $booking,
                timeWindow: $window,
                userId: (int) $user->id
            );

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

    private function assertCanUseBooking(Booking $booking, User $actor): void
    {
        $isOwner = $booking->user_id !== null && (int) $booking->user_id === (int) $actor->id;
        $isCreator = (int) $booking->created_by === (int) $actor->id;

        if (!($isOwner || $isCreator)) {
            abort(403, 'Нет доступа к этому бронированию');
        }
    }
}
