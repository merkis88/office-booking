<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UserUpdatePasswordRequest extends FormRequest
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
            'current_password' => 'required|current_password',
            'password' => 'required|string|min:8|confirmed',
            'password_confirmation' => 'required|string'
        ];
    }

    public function messages(): array
    {
        return [
            'current_password.required' => 'Текущий пароль обязателен!',
            'current_password.current_password' => 'Текущий пароль неверен!',
            'password.required' => 'Новый пароль обязателен!',
            'password.confirmed' => 'Пароли не совпадают!',
        ];
    }
}
