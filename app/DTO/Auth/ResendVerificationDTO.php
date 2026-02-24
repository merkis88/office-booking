<?php
namespace App\DTO\Auth;

use App\DTO\BaseDTO;

class ResendVerificationDTO extends BaseDTO
{
    public function __construct(
        public string $email,
    )
    {

    }
}
