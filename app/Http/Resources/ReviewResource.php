<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReviewResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'text' => $this->text,
            'rating' => $this->rating,
            'rating_stars' => $this->generateStars(),
            'user_id' => $this->user_id,
            'user' => new UserResource($this->whenLoaded('user')),
            'created_at' => $this->created_at->format('d.m.Y H:i'),
            'updated_at' => $this->updated_at->format('d.m.Y H:i'),
        ];
    }

     //генерирует строку со звёздами для отображения


    private function generateStars(): string
    {
        $filled = $this->rating;
        $empty = 5 - $filled;

        return str_repeat('&#9733;', $filled) . str_repeat('&#9734;', $empty);
    }
}
