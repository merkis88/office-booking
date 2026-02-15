<?php

namespace App\Http\Requests\Bookings;

use App\DTO\Bookings\AdminBookingsDTO;
use App\DTO\Bookings\CreateBookingDTO;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

final class CreateGuestBookingRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'place_id' => ['required', 'integer', 'exists:places,id'],
            'start_time' => ['required', 'date'],
            'end_time' => ['required', 'date', 'after:start_time'],
            'user_id' => ['prohibited'],
            'guest_name' => ['required', 'string', 'max:255', 'required_without:user_id'],
            'pass_type' => ['sometimes', Rule::in(['qr', 'pin'])],
        ];
    }

    public function toDTO(): CreateBookingDTO
    {
        return new CreateBookingDTO(
            placeId: (int) $this->input('place_id'),
            startTime: CarbonImmutable::parse($this->input('start_time')),
            endTime: CarbonImmutable::parse($this->input('end_time')),
            userId: null,
            guestName: (string) $this->input('guest_name'),
            passType: (string) ($this->input('pass_type') ?? 'qr'),
        );
    }
}
