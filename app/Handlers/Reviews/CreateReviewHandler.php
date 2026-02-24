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
    public function handle(CreateReviewDTO $dto, User $user): Review
    {
        if (!$user->hasVerifiedEmail()) {
            throw ValidationException::withMessages([
                'email' => ['Необходимо подтвердить email для создания отзыва']
            ]);
        }
        if($dto->rating < 1) {
            throw ValidationException::withMessages([
                'rating' => ['Выберите больше 0 звезд']
            ]);
        }

        return Review::create([
            'text' => $dto->text,
            'rating' => $dto->rating,
            'user_id' => $user->id,
        ]);
    }
}
