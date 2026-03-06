<?php

namespace App\Http\Requests\Services;

use App\DTO\Services\CreateServiceDTO;
use Illuminate\Foundation\Http\FormRequest;

class CreateServiceRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'booking_id' => 'required|integer|exists:bookings,id',
            'service_type_id' => 'required|integer|exists:service_types,id',
            'service_date' => 'required|date|after_or_equal:today',
            'service_time' => 'required|date_format:H:i',
            'comment' => 'nullable|string|max:1000',
        ];
    }
    public function messages(): array
    {
        return [
            'booking_id.required' => 'Выберите помещение',
            'booking_id.exists' => 'Помещение не найдено',
            'service_type_id.required' => 'Выберите тип заявки',
            'service_date.required' => 'Выберите дату',
            'service_date.after_or_equal' => 'Дата не может быть в прошлом',
            'service_time.required' => 'Выберите время',
        ];
    }
    public function toDTO(): CreateServiceDTO
    {
        return new CreateServiceDTO(
            booking_id: (int) $this->input('booking_id'),
            service_type_id: (int) $this->input('service_type_id'),
            service_date: $this->input('service_date'),
            service_time: $this->input('service_time'),
            comment: $this->input('comment'),
        );
    }
}
