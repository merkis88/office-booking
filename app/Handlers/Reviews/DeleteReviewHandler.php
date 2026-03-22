<?php
namespace App\Handlers\Reviews;

use App\Models\Review;

class DeleteReviewHandler
{
    public function handle(Review $review): void
    {
        $review->delete();
    }
}
