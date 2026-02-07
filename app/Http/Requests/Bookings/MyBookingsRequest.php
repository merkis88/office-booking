<?php

namespace App\Http\Requests\Bookings;

use App\DTO\Bookings\MyBookingsDTO;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

final class MyBookingsRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'status' => ['nullable', Rule::in(['pending', 'approved', 'rejected'])],
            'place_id' => ['nullable', 'integer', 'exists:places,id'],
            'from' => ['nullable', 'date'],
            'to'   => ['nullable', 'date'],
            'sort' => ['nullable', Rule::in(['start_time', '-start_time'])],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:100'],
        ];
    }

    public function toDTO(): MyBookingsDTO
    {
        $sort = $this->input('sort', '-start_time');

        return new MyBookingsDTO(
            status: $this->input('status'),
            placeId: $this->filled('place_id') ? (int) $this->input('place_id') : null,
            from: $this->filled('from') ? CarbonImmutable::parse($this->input('from')) : null,
            to: $this->filled('to') ? CarbonImmutable::parse($this->input('to')) : null,
            sortDirection: $sort === 'start_time' ? 'asc' : 'desc',
            perPage: (int) $this->input('per_page', 20),
        );

    }
}
