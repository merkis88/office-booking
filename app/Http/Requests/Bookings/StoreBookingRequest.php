<?php
namespace App\Http\Requests\Bookings;

use App\DTO\Bookings\CreateBookingDTO;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreBookingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;

    }

    public function rules(): array
    {
        return [
            'place_id' => ['required', 'integer', 'exists:places,id'],
            'start_time' => ['required', 'date'],
            'end_time' => ['required', 'date', 'after:start_time'],
            'user_id' => ['nullable', 'integer', 'exists:users,id', 'required_without:guest_name'],
            'guest_name' => ['nullable', 'string', 'max:255', 'required_without:user_id'],
            'pass_type' => ['sometimes', Rule::in(['qr', 'pin'])],
        ];
    }

    public function toDTO(): CreateBookingDTO
    {
        return new CreateBookingDTO(
            placeId: (int) $this->input('place_id'),
            startTime: CarbonImmutable::parse($this->input('start_time')),
            endTime: CarbonImmutable::parse($this->input('end_time')),
            userId: $this->filled('user_id') ? (int) $this->input('user_id') : null,
            guestName: $this->filled('guest_name') ? (string) $this->input('guest_name') : null,
            passType: (string) ($this->input('pass_type') ?? 'qr'),
        );
    }
}

