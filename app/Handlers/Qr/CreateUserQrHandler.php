<?php

namespace App\Handlers\Qr;

use App\DTO\Qr\CreateUserQrDTO;
use App\Models\Booking;
use App\Models\Qr;
use App\Models\User;
use App\Services\Qr\QrAccessValidator;
use App\Services\Qr\QrHashService;
use App\Services\Qr\QrWindowService;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

final class CreateUserQrHandler
{
    public function __construct(
        private readonly QrHashService $hashService,
        private readonly QrWindowService $windowService,
        private readonly QrAccessValidator $qrAccessValidator
    ) {}

    public function createForSelf(Booking $booking, User $user): Qr
    {
        $this->assertCanUseBooking($booking, $user);

        return $this->createOrGet($booking, $user->id);
    }

    public function handle(Booking $booking, User $actor, CreateUserQrDTO $dto): Qr
    {
        $this->assertCanUseBooking($booking, $actor);
        $this->qrAccessValidator->assertCanIssue($booking);

        $email = mb_strtolower(trim($dto->email));

        $targetUser = User::query()
            ->whereRaw('LOWER(email) = ?', [$email])
            ->first();

        if (!$targetUser) {
            throw ValidationException::withMessages([
                'email' => ['Пользователь с таким email не найден'],
            ]);
        }

        return $this->createOrGet($booking, $targetUser->id);
    }

    private function createOrGet(Booking $booking, $targetUserId): Qr
    {
        $window = $this->windowService->current();

        $existing = Qr::query()
            ->where('booking_id', $booking->id)
            ->where('time_window', $window)
            ->where('user_id', $targetUserId)
            ->first();

        if ($existing) {
            return $existing;
        }

        return DB::transaction(function () use ($booking, $targetUserId, $window) {
            $existing = Qr::query()
                ->where('booking_id', $booking->id)
                ->where('time_window', $window)
                ->where('user_id', $targetUserId)
                ->lockForUpdate()
                ->first();

            if ($existing) {
                return $existing;
            }

            $hash = $this->hashService->makeForUser(booking: $booking, timeWindow: $window, userId: $targetUserId);

            return Qr::query()->create([
                'booking_id' => $booking->id,
                'time_window' => $window,
                'user_id' => $targetUserId,
                'recipient_email' => null,
                'hash' => $hash,
                'used_at' => null,
            ]);
        });
    }

    private function assertCanUseBooking(Booking $booking, User $user): void
    {
        $isOwner = $booking->user_id !== null && (int) $booking->user_id === (int) $user->id;
        $isCreator = (int) $booking->created_by === (int) $user->id;

        if (!($isOwner || $isCreator)) {
            abort(403, 'Нет доступа к этому бронированию');
        }
    }
}
