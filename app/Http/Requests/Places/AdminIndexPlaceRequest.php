<?php
namespace App\Http\Requests\Places;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AdminIndexPlaceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'type' => ['nullable', Rule::in(['office', 'coworking', 'meeting'])],
            'is_active' => ['nullable', 'boolean'],
            'sort_by' => ['nullable', Rule::in(['name', 'created_at', 'capacity', 'number_place'])],
            'sort_direction' => ['nullable', Rule::in(['asc', 'desc'])],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:100'],
        ];
    }
}
