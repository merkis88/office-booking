<?php

namespace App\Http\Requests\Qr;

use Illuminate\Foundation\Http\FormRequest;
use App\DTO\Qr\CreateUserQrDTO;

final class CreateUserQrRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email', 'max:255'],
        ];
    }

    public function toDTO(): CreateUserQrDTO
    {
        return new CreateUserQrDTO (
            (string) $this->input('email'),
        );
    }
}
