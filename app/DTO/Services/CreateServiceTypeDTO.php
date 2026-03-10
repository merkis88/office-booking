<?php
namespace App\DTO\Services;

use App\DTO\BaseDTO;

class CreateServiceTypeDTO extends BaseDTO
{
    public function __construct(
        public string $name,
    )
    {

    }
}
