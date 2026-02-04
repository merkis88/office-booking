<?php
namespace App\DTO\Users;

use App\DTO\BaseDTO;

class UpdateUserDto extends BaseDTO
{
    public function __construct(
        public ?string $first_name,
        public ?string $last_name,
        public ?string $patronymic,
        public ?string $email,
        public ?string $photo,
    )
    {

    }
}
