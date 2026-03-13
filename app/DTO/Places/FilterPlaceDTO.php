<?php
namespace App\DTO\Places;

use App\DTO\BaseDTO;
use Carbon\CarbonImmutable;

class FilterPlaceDTO extends BaseDTO
{
    public function __construct(
        public ?float $min_price = null,
        public ?float $max_price = null,
        public ?CarbonImmutable $date = null,
    )
    {

    }
}
