<?php

namespace App\Handlers\Qr;

use App\DTO\Qr\CreateGuestQrDTO;
use App\Models\Booking;
use App\Models\Qr;
use App\Models\User;
use App\Services\Qr\QrHashService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\ValidationException;
use App\Mail\GuestQrMail;
use App\Services\Qr\QrWindowService;
use App\Services\Qr\QrAccessValidator;

final class CreateGuestQrHandler
{
    public function __construct(
        private readonly QrHashService $hashService,
        private readonly QrWindowService $windowService,
    ) {}


    public function handle(Booking $booking, User $tenant, CreateGuestQrDTO $dto): Qr
    {
        $this->assertCanUseBooking($booking, $tenant);

        $this->assertCanUseBooking($booking, $tenant);

        $email = mb_strtolower(trim($dto->recipientEmail));
        $window = $this->windowService->current();

        $qr = Qr::query()
            ->where('booking_id', $booking->id)
            ->where('time_window', $window)
            ->where('recipient_email', $email)
            ->first();

        if (!$qr) {
            $qr = DB::transaction(function () use ($booking, $tenant, $dto, $window, $email) {

                $existing = Qr::query()
                    ->where('booking_id', $booking->id)
                    ->where('time_window', $window)
                    ->where('recipient_email', $email)
                    ->lockForUpdate()
                    ->first();

                if ($existing) {
                    return $existing;
                }

                $hash = $this->hashService->makeForGuest($booking, $window, $email);

                return Qr::query()->create([
                    'booking_id' => $booking->id,
                    'time_window' => $window,
                    'user_id' => null,
                    'recipient_email' => $email,
                    'hash' => $hash,
                    'used_at' => null,
                ]);
            });

        }
        $booking->loadMissing('place');
        Mail::to($email)->send(new GuestQrMail($booking, $qr, $dto->guestName));

        return $qr;

    }

    private function assertCanUseBooking(Booking $booking, User $tenant): void
    {
        $isOwner = $booking->user_id !== null && (int) $booking->user_id === (int) $tenant->id;
        $isCreator = (int) $booking->created_by === (int) $tenant->id;

        if (!($isOwner || $isCreator)) {
            abort(403, 'Нет прав приглашать гостей в рамках этого бронирования');
        }
    }
}
