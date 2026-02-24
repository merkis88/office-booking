<?php

namespace App\DTO\Qr;

final class CreateGuestQrDTO
{
    public function __construct(
        public readonly string $recipientEmail,
        public readonly ?string $guestName,
        public readonly ?int $timeWindow,
    ) {}
}
