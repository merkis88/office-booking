<?php
namespace App\Handlers\Reviews;

use App\DTO\Reviews\UpdateReviewDTO;
use App\Models\Review;
use Illuminate\Validation\ValidationException;

class UpdateReviewHandler
{
    /**
     * Обновление отзыва
     *
     * @param Review $review
     * @param UpdateReviewDTO $dto
     * @return Review
     */
    public function handle(Review $review,UpdateReviewDTO $dto): Review
    {
        $data = [];

        if($dto->text !== null){
            $data['text'] = $dto->text;
        }
        if($dto->rating !== null){
            if($dto->rating < 1){
                throw ValidationException::withMessages([
                    'rating' => ['Выберите больше 0 звезд']
                ]);
            }
            $data['rating'] = $dto->rating;
        }

        if(empty($data)){
            return $review;
        }

        $review->update($data);
        return $review->fresh();
    }
}
