<?php

namespace App\DTO\Reviews;

use App\DTO\BaseDTO;

class ReviewFiltersDTO extends BaseDTO
{
    public function __construct(
        public ?string $sort_by = 'created_at',
        public ?int $rating = null,
        public ?string $sort_direction = 'desc',
    )
    {

    }
}
