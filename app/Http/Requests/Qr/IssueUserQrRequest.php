<?php

namespace App\Http\Requests\Qr;

use App\DTO\Qr\IssueUserQrDTO;
use Illuminate\Foundation\Http\FormRequest;

final class IssueUserQrRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'recipient_user_id' => ['required', 'integer', 'exists:users,id'],
        ];
    }

    public function toDTO(): IssueUserQrDTO
    {
        return new IssueUserQrDTO(
            recipientUserId: (int) $this->input('recipient_user_id'),
        );
    }
}
