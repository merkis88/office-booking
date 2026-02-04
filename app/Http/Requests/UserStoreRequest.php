<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UserStoreRequest extends FormRequest
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
            'role_id' => 'required|exists:roles,id',
            'first_name' => 'required|max:255',
            'last_name' => 'required|max:255',
            'patronymic' => 'sometimes|max:255',
            'email' => 'required|email|max:255|unique:users',
            'password' => 'required|min:6',
            'post' => 'max:100',
            'company' => 'max:100',
        ];
    }
}
