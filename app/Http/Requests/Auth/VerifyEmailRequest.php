<?php

namespace App\Http\Requests\Auth;

use App\DTO\Auth\VerifyEmailDTO;
use Illuminate\Foundation\Http\FormRequest;

class VerifyEmailRequest extends FormRequest
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
            'code' => 'required|string|size:6',
        ];
    }
    public function messages(): array
    {
        return [
            'email.required' => 'Email обязателен',
            'email.email' => 'Неверный формат email',
            'email.exists' => 'Пользователь с таким email не найден',
            'code.required' => 'Код подтверждения обязателен',
            'code.size' => 'Код должен содержать 6 символов',
        ];
    }
    public function toDTO(): VerifyEmailDTO
    {
        return new VerifyEmailDTO(
            email: $this->input('email'),
            code: $this->input('code'),
        );
    }
}
