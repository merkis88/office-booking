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
            'start_time' => ['required', 'date_format:Y-m-d\TH:i:sP'],
            'end_time'   => ['required', 'date_format:Y-m-d\TH:i:sP', 'after:start_time'],
            'pass_type' => ['sometimes', Rule::in(['qr', 'pin'])],
        ];
    }

    public function toDTO(): CreateBookingDTO
    {
        return new CreateBookingDTO(
            placeId: (int) $this->input('place_id'),
            startTime: CarbonImmutable::parse($this->input('start_time'))->utc(),
            endTime: CarbonImmutable::parse($this->input('end_time'))->utc(),
            passType: (string) ($this->input('pass_type') ?? 'qr'),
        );
    }
}

