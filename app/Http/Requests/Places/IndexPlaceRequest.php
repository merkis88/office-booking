<?php
namespace App\Http\Requests\Places;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class IndexPlaceRequest extends FormRequest
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
            'type' => ['nullable', Rule::in(['office', 'coworking', 'meeting'])],
        ];
    }
    public function messages(): array
    {
        return [
            'type.in' => 'Тип помещения должен быть: office, coworking, meeting',
        ];
    }
}
