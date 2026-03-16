<?php

namespace App\Http\Requests\Profile;

use Illuminate\Foundation\Http\FormRequest;

final class DeleteProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'password' => ['required', 'string'],
        ];
    }
}
