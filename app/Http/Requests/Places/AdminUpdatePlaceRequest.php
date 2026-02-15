<?php

namespace App\Http\Requests\Places;

use App\DTO\Places\UpdatePlaceDTO;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AdminUpdatePlaceRequest extends FormRequest
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
            'name' => 'sometimes|string|max:255',
            'type' => ['sometimes', Rule::in(['office', 'coworking', 'meeting'])],
            'capacity' => 'sometimes|integer|min:1',
            'number_place' => 'sometimes|integer|min:1',
            'price' => 'sometimes|numeric|min:0|max:99999999.99',
            'photo' => 'nullable|string|max:2048',
            'description' => 'nullable|string|max:5000',
            'is_active' => 'sometimes|boolean',
        ];
    }

    public function toDTO(): UpdatePlaceDTO
    {
        return new UpdatePlaceDTO(
            name: $this->input('name'),
            type: $this->input('type'),
            capacity: $this->filled('capacity') ? (int)$this->input('capacity') : null,
            number_place: $this->filled('number_place') ? (int)$this->input('number_place') : null,
            is_active: $this->has('is_active') ? $this->boolean('is_active') : null,
            price: $this->filled('price') ? (float)$this->input('price') : null,
            photo: null,
            description: $this->input('description'),
        );
    }
}
