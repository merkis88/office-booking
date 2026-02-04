<?php
namespace App\DTO\Auth;

use App\DTO\BaseDTO;

class PasswordResetDTO extends BaseDTO
{
    public function __construct(
        public string $token,
        public string $email,
        public string $password,
        public string $password_confirmation,
    )
    {

    }
}
