<?php

namespace App\Http\Requests\Services;

use App\DTO\Services\CreateServiceTypeDTO;
use Illuminate\Foundation\Http\FormRequest;

class CreateServiceTypeRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return $this->user() && $this->user()->role->role_name === 'admin';
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255|unique:service_types,name',
        ];
    }
    public function messages(): array
    {
        return [
            'name.required' => 'Название заявки обязательно',
            'name.unique' => 'Такая заявка уже существует',
        ];
    }
    public function toDTO(): CreateServiceTypeDTO
    {
        return new CreateServiceTypeDTO(
            name: $this->input('name'),
        );
    }
}
