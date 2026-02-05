<?php

namespace App\Http\Requests\Bookings;

use App\DTO\Bookings\AdminBookingsDTO;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

final class AdminBookingsRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'status' => ['nullable', Rule::in(['pending', 'approved', 'rejected'])],
            'place_id' => ['nullable', 'integer', 'exists:places,id'],
            'user_id' => ['nullable', 'integer', 'exists:users,id'],
            'created_by' => ['nullable', 'integer', 'exists:users,id'],
            'from' => ['nullable', 'date'],
            'to' => ['nullable', 'date'],
            'sort' => ['nullable', Rule::in(['start_time', '-start_time'])],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:100'],
        ];
    }

    public function toDTO(): AdminBookingsDTO
    {
        $sort = $this->input('sort', '-start_time');

        return new AdminBookingsDTO(
            status: $this->input('status'),
            placeId: $this->filled('place_id') ? (int) $this->input('place_id') : null,
            userId: $this->filled('user_id') ? (int) $this->input('user_id') : null,
            createdBy: $this->filled('created_by') ? (int) $this->input('created_by') : null,
            from: $this->filled('from') ? CarbonImmutable::parse($this->input('from')) : null,
            to: $this->filled('to') ? CarbonImmutable::parse($this->input('to')) : null,
            sortDirection: $sort === 'start_time' ? 'asc' : 'desc',
            perPage: (int) $this->input('per_page', 20),
        );
    }
}
