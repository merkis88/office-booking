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

final class CreateGuestQrHandler
{
    public function __construct(private readonly QrHashService $hashService) {}

    private int $windowSeconds = 1800;
    private int $beforeMinutes = 30;
    private int $afterMinutes  = 15;

    public function handle(Booking $booking, User $user, CreateGuestQrDTO $dto): Qr
    {
        $this->assertCanInvite($booking, $user);
        $this->assertQrAllowed($booking);

        $email = mb_strtolower(trim($dto->recipientEmail));
        $window = $dto->timeWindow ?? $this->currentWindow();

        $qr = Qr::query()
            ->where('booking_id', $booking->id)
            ->where('time_window', $window)
            ->where('recipient_email', $email)
            ->first();

        if (!$qr) {
            $qr = DB::transaction(function () use ($booking, $user, $dto, $window, $email) {

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

    private function currentWindow(): int
    {
        return intdiv(now()->timestamp, $this->windowSeconds);
    }

    private function assertCanInvite(Booking $booking, User $user): void
    {
        $isOwner = $booking->user_id !== null && (int) $booking->user_id === (int) $user->id;
        $isCreator = (int) $booking->created_by === (int) $user->id;

        if (!($isOwner || $isCreator)) {
            abort(403, 'Нет прав приглашать гостей в рамках этого бронирования');
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
