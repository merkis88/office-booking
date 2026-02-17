<?php

namespace App\Http\Requests\Places;

use Illuminate\Foundation\Http\FormRequest;

class AdminStorePhotoPlaceRequest extends FormRequest
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
            'photo' => 'required|image|mimes:jpeg,png,jpg,gif|max:5120',
        ];
    }
    public function messages(): array
    {
        return [
            'photo.required' => 'Файл фото обязателен',
            'photo.image' => 'Файл должен быть изображением',
            'photo.mimes' => 'Допустимые форматы: jpeg, png, jpg, gif',
            'photo.max' => 'Размер файла не должен превышать 5MB',
        ];
    }
}
