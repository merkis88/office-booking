<?php

namespace App\Http\Requests\Services;

use App\DTO\Services\UpdateServiceTypeDTO;
use Illuminate\Foundation\Http\FormRequest;

class UpdateServiceTypeRequest extends FormRequest
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
            'name' => 'sometimes|string|max:255|unique:service_types,name,',
        ];
    }
    public function toDTO(): UpdateServiceTypeDTO
    {
        return new UpdateServiceTypeDTO(
            name: $this->input('name'),
        );
    }
}
