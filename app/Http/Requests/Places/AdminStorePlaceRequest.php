<?php

namespace App\Http\Requests\Places;

use App\DTO\Places\CreatePlaceDTO;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AdminStorePlaceRequest extends FormRequest
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
            'name' => 'required|string|max:255',
            'type' => ['required', Rule::in(['office', 'coworking', 'meeting'])],
            'capacity' => 'required|integer|min:1',
            'number_place' => 'required|integer|min:1',
            'price' => 'required|numeric|min:0|max:99999999.99',
            'photo' => 'required|image|mimes:jpeg,png,jpg,gif|max:5120',
            'description' => 'required|string|max:5000',
            'is_active' => 'sometimes|boolean',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Название помещения обязательно',
            'type.required' => 'Тип помещения обязателен',
            'type.in' => 'тип помещения должен быть: office,coworking, meeting',
            'capacity.required' => 'Вместимость обязательна',
            'capacity.min' => 'Вместимость не может быть меньше 1',
            'number_place.required' => 'Номер помещения обязателен',
            'price.required' => 'Цена аренды обязательна',
            'price.numeric' => 'Цена должна быть числом',
            'price.min' => 'Цена не может быть отрицательной',
            'photo.image' => 'Файл должен быть изображением',
            'photo.mimes' => 'Допустимые форматы: jpeg, png, jpg, gif',
            'photo.max' => 'Размер файла не должен превышать 5MB',
        ];
    }

    public function toDTO(): CreatePlaceDTO
    {
        return new CreatePlaceDTO(
            name: $this->input('name'),
            type: $this->input('type'),
            capacity: (int)$this->input('capacity'),
            number_place: (int)$this->input('number_place'),
            price: (float)$this->input('price'),
            photo: null,
            description: $this->input('description'),
            is_active: $this->boolean('is_active', true),
        );
    }
}
