<?php
namespace App\DTO\Auth;

use App\DTO\BaseDTO;

class RegisterDTO extends BaseDTO
{
    public function __construct(
        public string $first_name,
        public string $last_name,
        public ?string $patronymic,
        public string $email,
        public string $password,
        public string $password_confirmation,
        public ?int $role_id,
        public ?string $post,
        public ?string $company,
        public ?string $photo,
    )
    {

    }
}
