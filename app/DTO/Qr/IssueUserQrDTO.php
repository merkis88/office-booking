<?php

namespace App\DTO\Qr;

final class IssueUserQrDTO
{
    public function __construct(
        public readonly int $recipientUserId
    ) {}
}
