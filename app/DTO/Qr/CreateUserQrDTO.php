<?php

namespace App\DTO\Qr;

final class CreateUserQrDTO
{
    public function __construct(
        public readonly string $email,
    ) {}
}
