<?php

namespace App\Handlers\Profile;

use App\Handlers\Qr\CreateUserQrHandler;
use App\Models\Booking;
use App\Models\Qr;
use App\Models\User;
use App\Services\Qr\QrAvailabilityService;
use App\Services\Qr\QrWindowService;
use App\DTO\Qr\CreateUserQrDTO;
use Illuminate\Support\Facades\Storage;

final class GetProfileHandler
{
    public function __construct(
        private readonly QrAvailabilityService $availabilityService,
        private readonly QrWindowService $windowService,
        private readonly CreateUserQrHandler $createUserQrHandler,
    ) {}

    public function handle(User $user): array
    {
        $booking = Booking::query()
            ->select('bookings.*')
            ->join('qrs', 'qrs.booking_id', '=', 'bookings.id')
            ->where('qrs.user_id', $user->id)
            ->where('bookings.status', 'active')
            ->where('bookings.pass_type', 'qr')
            ->where('bookings.end_time', '>=', now())
            ->orderBy('bookings.start_time')
            ->first();

        $qrHash = null;
        $qrVisible = false;
        $qrMessage = null;
        $qrAvailableFrom = null;
        $qrAvailableUntil = null;
        $currentWindow = null;

        if ($booking) {

            $availability = $this->availabilityService->getAvailability($booking);

            $qrVisible = $availability['qr_visible'];
            $qrMessage = $availability['qr_message'];
            $qrAvailableFrom = $availability['qr_available_from'];
            $qrAvailableUntil = $availability['qr_available_until'];

            if ($qrVisible) {
                $currentWindow = $this->windowService->current();

                $qr = Qr::query()
                    ->where('booking_id', $booking->id)
                    ->where('user_id', $user->id)
                    ->where('time_window', $currentWindow)
                    ->first();

                if (!$qr) {
                    $qr = $this->createUserQrHandler->handle($booking,  $user, $currentWindow);
                }

                $qrHash = $qr->hash;
            }
        }

        return [
            'id' => $user->id,
            'photo_url' => $user->photo ? Storage::disk('public')->url($user->photo) : null,
            'first_name' => $user->first_name,
            'last_name' => $user->last_name,
            'patronymic' => $user->patronymic,
            'phone' => $user->phone,
            'email' => $user->email,

            'qr_hash' => $qrHash,
            'qr_visible' => $qrVisible,
            'qr_message' => $qrMessage,
            'qr_available_from' => $qrAvailableFrom,
            'qr_available_until' => $qrAvailableUntil,
            'qr_time_window' => $currentWindow,

            'qr_booking' => $booking ? [
                'id' => $booking->id,
                'place_id' => $booking->place_id,
                'start_time' => $booking->start_time,
                'end_time' => $booking->end_time,
                'status' => $booking->status,
                'pass_type' => $booking->pass_type,
                'timezone' => config('booking.timezone', 'UTC'),
            ] : null,

            'created_at' => $user->created_at,
            'updated_at' => $user->updated_at,
        ];
    }
}
