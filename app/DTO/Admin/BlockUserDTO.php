<?php

namespace App\DTO\Admin;

final class BlockUserDTO
{
    public function __construct(
        public readonly string $email,
        public readonly ?string $reason,
    ) {}
}
