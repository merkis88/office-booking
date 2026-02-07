<?php
namespace App\DTO\Reviews;

use App\DTO\BaseDTO;

class CreateReviewDTO extends BaseDTO
{
    public function __construct(
        public string $text,
        public int $rating,
        public int $user_id,
    )
    {

    }
}
