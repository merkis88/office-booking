<?php
namespace App\DTO\Users;

use App\DTO\BaseDTO;

class UpdatePasswordDTO extends BaseDTO
{
    public function __construct(
        public string $current_password,
        public string $password,
        public string $password_confirmation,
    )
    {

    }
}
