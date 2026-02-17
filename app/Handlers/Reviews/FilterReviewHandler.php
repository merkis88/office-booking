<?php
namespace App\Handlers\Reviews;

use App\DTO\Reviews\ReviewFiltersDTO;
use App\Models\Review;
use Illuminate\Database\Eloquent\Collection;

class FilterReviewHandler
{
    public function handle(ReviewFiltersDTO $dto): Collection
    {
        $query = Review::with('user');

        if($dto->rating !== null){
            $query->where('rating', $dto->rating);
        }

        $sortField = $dto->sort_by === 'rating' ? 'rating' : 'created_at';
        $query->orderBy($sortField, $dto->sort_direction);
        if($dto->sort_by === 'rating'){
            $query->orderBy('created_at', 'desc');
        }

        return $query->get();
    }
}
