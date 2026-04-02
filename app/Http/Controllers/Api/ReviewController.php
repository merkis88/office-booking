<?php

namespace App\Http\Controllers\Api;

use App\DTO\Reviews\CreateReviewDTO;
use App\DTO\Reviews\UpdateReviewDTO;
use App\Handlers\Reviews\CreateReviewHandler;
use App\Handlers\Reviews\DeleteReviewHandler;
use App\Handlers\Reviews\FilterReviewHandler;
use App\Handlers\Reviews\UpdateReviewHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Reviews\CreateReviewRequest;
use App\Http\Requests\Reviews\DeleteReviewRequest;
use App\Http\Requests\Reviews\ReviewFiltersRequest;
use App\Http\Requests\Reviews\UpdateReviewRequest;
use App\Http\Resources\ReviewResource;
use App\Models\Review;

class ReviewController extends Controller
{
    public function __construct(
        private CreateReviewHandler $createReviewHandler,
        private UpdateReviewHandler $updateReviewHandler,
        private DeleteReviewHandler $deleteReviewHandler,
        private FilterReviewHandler $filterReviewHandler,
    ) {}

    public function index(ReviewFiltersRequest $request)
    {
        $dto = $request->toDTO();
        $reviews = $this->filterReviewHandler->handle($dto);

        return ReviewResource::collection($reviews);
    }

    public function show(Review $review)
    {
        $review->load('user');

        return new ReviewResource($review);
    }

    public function store(CreateReviewRequest $request)
    {
        $dto = CreateReviewDTO::fromRequest($request->validated());
        $review = $this->createReviewHandler->handle($dto, $request->user());

        return response()->json([
            'message' => 'Отзыв успешно добавлен!',
            'data' => new ReviewResource($review->load('user')),
        ], 201);
    }

    public function update(UpdateReviewRequest $request, Review $review)
    {
        $dto = UpdateReviewDTO::fromRequest($request->validated());
        $updatedReview = $this->updateReviewHandler->handle($review, $dto);

        return response()->json([
            'message' => 'Отзыв обновлен',
            'data' => new ReviewResource($updatedReview->load('user')),
        ]);
    }

    public function destroy(DeleteReviewRequest $request, Review $review)
    {
        $this->deleteReviewHandler->handle($review);

        return response()->json([
            'message' => 'Отзыв успешно удален',
        ]);
    }

    public function userReviews($userId)
    {
        $reviews = Review::where('user_id', $userId)->with('user')->latest()->get();

        return ReviewResource::collection($reviews);
    }
}
