<?php
namespace App\DTO\Reviews;

use App\DTO\BaseDTO;

class UpdateReviewDTO extends BaseDTO
{
    public function __construct(
        public ?string $text = null,
        public ?int $rating,
    )
    {

    }
}
