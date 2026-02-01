<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
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
            'first_name'=>'required|string|max:255',
            'last_name'=>'required|string|max:255',
            'patronymic'=>'nullable|string|max:255',
            'email'=>'required|email|unique:users,email',
            'password'=>['required', 'confirmed', Password::defaults()],
            'role_id'=>'exists:roles,id',
            'post' => 'nullable|string|max:255',
            'company' => 'nullable|string|max:255',
            'photo' => 'nullable|string|max:255',
        ];
    }
    public function messages(): array{
        return [
            'email.unique' => 'Пользователь с таким email уже существует',
            'password.confirmed' => 'Пароли не совпадают',
        ];
    }
}
