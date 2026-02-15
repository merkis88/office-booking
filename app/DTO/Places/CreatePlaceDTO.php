<?php
namespace App\DTO\Places;

use App\DTO\BaseDTO;

class CreatePlaceDTO extends BaseDTO
{
    public function __construct(
        public string $name,
        public string $type,
        public int $capacity,
        public int $number_place,
        public float $price,
        public ?string $photo = null,
        public string $description,
        public bool $is_active = true,
    )
    {

    }
}
