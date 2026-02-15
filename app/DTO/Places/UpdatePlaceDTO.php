<?php
namespace App\DTO\Places;

use App\DTO\BaseDTO;

class UpdatePlaceDTO extends BaseDTO
{
    public function __construct(
        public ?string $name = null,
        public ?string $type = null,
        public ?int $capacity = null,
        public ?int $number_place = null,
        public ?bool $is_active = null,
        public ?float $price = null,
        public ?string $photo = null,
        public ?string $description = null,
    )
    {

    }
}
