<?php

namespace App\Http\Requests\Auth;

use App\DTO\Auth\ForgotPasswordDTO;
use Illuminate\Foundation\Http\FormRequest;

class ForgotPasswordRequest extends FormRequest
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
            'email' => 'required|email|exists:users,email',
        ];
    }
    public function messages(): array
    {
        return [
            'email.required' => 'Email обязателен',
            'email.email' => 'Неверный формат email',
            'email.exists' => 'Пользователь с таким email не найден',
        ];
    }
    public function toDTO(): ForgotPasswordDTO
    {
        return new ForgotPasswordDTO(
            email: $this->input('email'),
        );
    }
}
