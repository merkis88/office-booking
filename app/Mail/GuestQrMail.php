<?php

namespace App\Mail;

use App\Models\Booking;
use App\Models\Qr;
use App\Services\Qr\QrPngService;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

final class GuestQrMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public readonly Booking $booking, public readonly Qr $qr, public readonly ?string $guestName = null) {}

    public function build(): self
    {
        $payload = (string) $this->qr->hash;

        $png = app(QrPngService::class)->makePng($payload);

        return $this->subject('Ваш QR для входа в бизнес-центр "Рабочая точка."')
            ->view('emails.guest_qr')
            ->with([
                'guestName' => $this->guestName,
                'placeName' => optional($this->booking->place)->name,
                'startTime' => $this->booking->start_time,
                'endTime' => $this->booking->end_time,
                'hash' => $this->qr->hash,
                'qrPng' => $png,
            ])
            ->attachData($png, 'qr.png', ['mime' => 'image/png']);
    }


}
