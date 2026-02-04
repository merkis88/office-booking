<?php

namespace App\Http\Requests\ResetPassword;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class PasswordResetRequest extends FormRequest
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
            'token' => 'required',
            'email' => 'required|email|exists:users,email',
            'password' => ['required', 'confirmed', Password::defaults()],
        ];
    }
    public function messages(): array
    {
        return [
            'token.required' => 'Токен обязателен',
            'email.required' => 'Email обязателен',
            'email.email' => 'Неверный формат email',
            'email.exists' => 'Пользователь с таким email не найден',
            'password.required' => 'Пароль обязателен',
            'password.confirmed' => 'Пароли не совпадают',
        ];
    }
}
