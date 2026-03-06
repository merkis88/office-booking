<?php
namespace App\DTO\Services;

use App\DTO\BaseDTO;

class UpdateServiceStatusDTO extends BaseDTO
{
    public function __construct(
        public string $status,
    )
    {

    }
}
