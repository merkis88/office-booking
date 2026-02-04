<?php

namespace App\Http\Requests\Bookings;

use App\DTO\Bookings\RescheduleBookingDTO;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Http\FormRequest;

final class RescheduleBookingRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'start_time' => ['required', 'date'],
            'end_time'   => ['required', 'date', 'after:start_time'],
        ];
    }

    public function toDTO(): RescheduleBookingDTO
    {
        return new RescheduleBookingDTO(
            startTime: CarbonImmutable::parse($this->input('start_time')),
            endTime: CarbonImmutable::parse($this->input('end_time')),
        );
    }
}
