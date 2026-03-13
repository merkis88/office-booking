<?php

namespace App\Http\Requests\Places;

use App\DTO\Places\FilterPlaceDTO;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Http\FormRequest;

class FilterPlaceRequest extends FormRequest
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
            'min_price' => ['nullable', 'numeric', 'min:0'],
            'max_price' => ['nullable', 'numeric', 'min:0', 'gte:min_price'],
            'date' => ['nullable', 'date'],
        ];
    }
    public function messages(): array
    {
        return [
            'min_price.min' => 'Минимальная цена не может быть отрицательной',
            'max_price.min' => 'Максимальная цена не может быть отрицательной',
            'max_price.gte' => 'Максимальная цена должна быть больше или равна минимальной',
        ];
    }
    public function toDTO(): FilterPlaceDTO
    {
        return new FilterPlaceDTO(
            min_price: $this->filled('min_price') ? (float) $this->input('min_price') : null,
            max_price: $this->filled('max_price') ? (float) $this->input('max_price') : null,
            date: $this->filled('date') ? CarbonImmutable::parse($this->input('date')) : null,
        );
    }
}
