<?php

namespace App\DTO\Qr;

final class IssueUserQrDTO
{
    public function __construct(
        public readonly int $recipientUserId,
        public readonly string $recipientEmail,
        public readonly ?string $guestName = null,
    ) {}
}
