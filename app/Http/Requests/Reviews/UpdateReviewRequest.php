<?php

namespace App\Http\Requests\Reviews;

use Illuminate\Foundation\Http\FormRequest;

class UpdateReviewRequest extends FormRequest
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
            'text' => 'sometimes|min:16|max:1000',
            'rating' => 'sometimes|integer|in:1,2,3,4,5',
        ];
    }
    public function messages(): array
    {
        return [
            'rating.in' => 'Выберите от 1 до 5 звёзд',
        ];
    }
}
