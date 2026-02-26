<?php
namespace App\DTO\Auth;

use App\DTO\BaseDTO;

class ForgotPasswordDTO extends BaseDTO
{
    public function __construct(
        public string $email,
    ) {}
}
