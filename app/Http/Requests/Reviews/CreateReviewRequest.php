<?php

namespace App\Http\Requests\Reviews;

use Illuminate\Foundation\Http\FormRequest;

class CreateReviewRequest extends FormRequest
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
            'text' => 'required|string|min:16|max:1000',
            'rating' => 'required|integer|between:1,5',
            'user_id' => 'required|exists:users,id'
        ];
    }
    public function messages(): array
    {
        return [
            'text.required' => 'Напишите текст отзыва',
            'text.min' => 'Отзыв должен содержать минимум 16 символов',
            'text.max' => 'Отзыв не должен превышать 1000 символов',
            'rating.required' => 'Выберите рейтинг звёздами',
            'rating.between' => 'Выберите от 1 до 5 звёзд',
            'user_id.required' => 'Пользователь не указан',
            'user_id.exists' => 'Пользователь не найден',
        ];
    }
}
