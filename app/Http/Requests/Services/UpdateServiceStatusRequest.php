<?php

namespace App\Http\Requests\Services;

use App\DTO\Services\UpdateServiceStatusDTO;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateServiceStatusRequest extends FormRequest
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
            'status' => ['required', Rule::in(['pending', 'in_progress', 'completed', 'rejected'])],
        ];
    }
    public function toDTO(): UpdateServiceStatusDTO
    {
        return new UpdateServiceStatusDTO(
            status: $this->input('status'),
        );
    }
}
