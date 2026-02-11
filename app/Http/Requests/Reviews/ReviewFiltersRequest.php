<?php

namespace App\Http\Requests\Reviews;

use App\DTO\Reviews\ReviewFiltersDTO;
use Illuminate\Foundation\Http\FormRequest;

class ReviewFiltersRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'rating' => 'required|integer|in:1,2,3,4,5',
            'sort_by' => 'nullable|string|in:created_at,rating',
            'sort_direction' => 'nullable|string|in:asc,desc',
        ];
    }

    public function toDTO(): ReviewFiltersDTO
    {
        return new ReviewFiltersDTO(
            sort_by: $this->input('sort_by', 'created_at'),
            rating: $this->input('rating') ? (int)$this ->input('rating') : null,
            sort_direction: $this->input('sort_direction', 'desc'),
        );
    }
}
