<?php

namespace App\Http\Requests\Bookings;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

final class ExtendBookingRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'minutes' => ['nullable', 'integer', 'min:1', 'max:1440', 'required_without:preset'],
            'preset' => ['nullable', Rule::in(['10m', '1h', '1d']), 'required_without:minutes'],
        ];
    }

    public function minutes(): int
    {
        if ($this->filled('minutes')) {
            return (int) $this->input('minutes');
        }

        return match ((string) $this->input('preset')) {
            '10m' => 10,
            '1h' => 60,
            '1d' => 1440,
            default => 0,
        };
    }
}
