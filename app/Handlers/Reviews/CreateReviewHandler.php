<?php
namespace App\Handlers\Reviews;

use App\DTO\Reviews\CreateReviewDTO;
use App\Models\Review;
use App\Models\User;
use Illuminate\Validation\ValidationException;

class CreateReviewHandler
{
    /**
     * Создание нового отзыва
     *
     * @param CreateReviewDTO $dto
     * @return Review
     */
    public function handle(CreateReviewDTO $dto): Review
    {
        if($dto->rating < 1) {
            throw ValidationException::withMessages([
                'rating' => ['Выберите больше 0 звезд']
            ]);
        }

        $user = User::findOrFail($dto->user_id);
        return Review::create([
            'text' => $dto->text,
            'rating' => $dto->rating,
            'user_id' => $dto->user_id,
        ]);
    }
}
