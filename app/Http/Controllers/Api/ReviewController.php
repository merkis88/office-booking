<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Reviews\CreateReviewRequest;
use App\Http\Requests\Reviews\UpdateReviewRequest;
use App\Handlers\Reviews\CreateReviewHandler;
use App\Handlers\Reviews\UpdateReviewHandler;
use App\Handlers\Reviews\DeleteReviewHandler;
use App\DTO\Reviews\CreateReviewDTO;
use App\DTO\Reviews\UpdateReviewDTO;
use App\Http\Resources\ReviewResource;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class ReviewController extends Controller
{
    public function __construct(
        private CreateReviewHandler $createReviewHandler,
        private UpdateReviewHandler $updateReviewHandler,
        private DeleteReviewHandler $deleteReviewHandler,
    )
    {

    }

    public function index()
    {
        $reviews = Review::with('user')->latest()->get();
        return ReviewResource::collection($reviews);
    }

    public function show(Review $review)
    {
        $review->load('user');
        return new ReviewResource($review);
    }

    public function store(CreateReviewRequest $request)
    {
        try {
            $dto = CreateReviewDTO::fromRequest($request->validated());
            $review = $this->createReviewHandler->handle($dto);

            return response()->json([
                'success' => true,
                'message' => 'Отзыв успешно добавлен!',
                'data' => new ReviewResource($review->load('user'))
            ],201);
        }
        catch(ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Ошибка валидации',
                'errors' => $e->errors()
            ],422);
        }
    }

    public function update(UpdateReviewRequest $request, Review $review)
    {
        try{
            $dto = UpdateReviewDTO::fromRequest($request->validated());
            $updatedReview = $this->updateReviewHandler->handle($review,$dto);

            return response()->json([
                'success' => true,
                'message' => 'Отзыв обновлен',
                'data' => new ReviewResource($updatedReview->load('user'))
            ]);
        }
        catch(ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Ошибка валидации',
                'errors' => $e->errors()
            ],422);
        }
    }
    public function destroy(Review $review)
    {
        $this->deleteReviewHandler->handle($review);

        return response()->json([
            'success' => true,
            'message' => 'Отзыв успешно удален'
        ]);
    }

    public function userReviews($userId)
    {
        $reviews = Review::where('user_id', $userId)->with('user')->latest()->get();

        return ReviewResource::collection($reviews);
    }
}
