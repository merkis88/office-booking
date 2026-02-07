<?php
namespace App\Handlers\Reviews;

use App\Models\Review;

class DeleteReviewHandler
{
    /**
     * Удаление отзыва
     *
     * @param Review $review
     * @return void
     */
    public function handle(Review $review): void
    {
        $review->delete();
    }
}
