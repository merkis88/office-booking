<?php
namespace App\DTO\Users;

use App\DTO\BaseDTO;

class CreateUserDTO extends BaseDTO
{
    public function __construct(
        public int $role_id,
        public string $first_name,
        public string $last_name,
        public ?string $patronymic,
        public string $email,
        public string $password,
        public ?string $post,
        public ?string $company,
        public ?string $photo,
    )
    {

    }
}
