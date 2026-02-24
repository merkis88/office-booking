<?php
namespace App\DTO\Auth;

use App\DTO\BaseDTO;

class VerifyEmailDTO extends BaseDTO
{
    public function __construct(
        public string $email,
        public string $code,
    )
    {

    }
}
