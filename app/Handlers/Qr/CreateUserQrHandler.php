<?php

namespace App\Handlers\Qr;

use App\Models\Booking;
use App\Models\Qr;
use App\Models\User;
use App\Services\Qr\QrHashService;
use App\Services\Qr\QrWindowService;
use Illuminate\Support\Facades\DB;
use App\DTO\Qr\CreateUserQrDTO;
use Nette\Schema\ValidationException;

final class CreateUserQrHandler
{
    public function __construct(private readonly QrHashService $hashService, private readonly QrWindowService $windowService) {}

    public function handle(Booking $booking, User $tenant, CreateUserQrDTO $dto): Qr
    {
        $this->assertCanUseBooking($booking, $tenant);

        $email = mb_strtolower(trim($dto->email));

        $targetUser = User::query()
            ->whereRaw('LOWER(email) = ?', [$email])
            ->first();

        if (!$targetUser) {
            throw ValidationException::withMessages([
                'email' => ['Пользователь с таким email не найден']
            ]);
        }

        $window = $this->windowService->current();

        $existing = Qr::query()
            ->where('booking_id', $booking->id)
            ->where('time_window', $window)
            ->where('user_id', $targetUser->id)
            ->first();

        if ($existing) {
            return $existing;
        }

        return DB::transaction(function () use ($booking, $targetUser, $window) {
            $existing = Qr::query()
                ->where('booking_id', $booking->id)
                ->where('time_window', $window)
                ->where('user_id', $targetUser->id)
                ->lockForUpdate()
                ->first();

            if ($existing) {
                return $existing;
            }

            $hash = $this->hashService->makeForUser(
                booking: $booking,
                timeWindow: $window,
                userId: $targetUser->id
            );

            return Qr::query()->create([
                'booking_id' => $booking->id,
                'time_window' => $window,
                'user_id' => $targetUser->id,
                'recipient_email' => null,
                'hash' => $hash,
                'used_at' => null,
            ]);
        });
    }

    private function assertCanUseBooking(Booking $booking, User $tenant): void
    {
        $isOwner = $booking->user_id !== null && (int) $booking->user_id === (int) $tenant->id;
        $isCreator = (int) $booking->created_by === (int) $tenant->id;

        if (!($isOwner || $isCreator)) {
            abort(403, 'Нет доступа к этому бронированию');
        }
    }
}
