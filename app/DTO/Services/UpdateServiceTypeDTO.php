<?php
namespace App\DTO\Services;

use App\DTO\BaseDTO;

class UpdateServiceTypeDTO extends BaseDTO
{
    public function __construct(
        public ?string $name = null,
    )
    {

    }
}
