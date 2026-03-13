<?php

namespace App\Http\Requests\Admin\User;

use App\DTO\Admin\BlockUserDTO;
use Illuminate\Foundation\Http\FormRequest;

final class BlockUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email'  => ['required', 'email', 'exists:users,email'],
            'reason' => ['nullable', 'string', 'max:1000'],
        ];
    }

    public function toDTO(): BlockUserDTO
    {
        return new BlockUserDTO(
            email: (string) $this->input('email'),
            reason: $this->input('reason'),
        );
    }
}
