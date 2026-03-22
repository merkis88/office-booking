<?php

namespace App\Http\Requests\Qr;

use App\DTO\Qr\CreateGuestQrDTO;
use Illuminate\Foundation\Http\FormRequest;

final class CreateGuestQrRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'recipient_email' => ['required', 'email', 'max:255'],
            'guest_name' => ['nullable', 'string', 'max:255'],
        ];
    }

    public function toDTO(): CreateGuestQrDTO
    {
        return new CreateGuestQrDTO(
            (string) $this->input('recipient_email'),
            $this->input('guest_name'),
        );
    }
}
