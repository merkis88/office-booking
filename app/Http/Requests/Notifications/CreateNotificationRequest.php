<?php

namespace App\Http\Requests\Notifications;

use App\DTO\Notifications\CreateNotificationDTO;
use Illuminate\Foundation\Http\FormRequest;

class CreateNotificationRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return $this->user() && $this->user()->role->role_name === 'admin';
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'message' => 'required|string|max:5000',
            'send_to_employee' => 'sometimes|boolean',
            'user_email' => [
                'required_if:send_to_employee,true',
                'prohibited_if:send_to_employee,false',
                'email',
                'exists:users,email',
            ]
        ];
    }
    public function messages(): array
    {
        return [
            'title.required' => 'Тема уведомления обязательна',
            'message.required' => 'Текст уведомления обязателен',
            'user_email.required_if' => 'Укажите email сотрудника',
            'user_email.email' => 'Неверный формат email',
            'user_email.exists' => 'Пользователь с таким email не найден',
        ];
    }

    public function toDTO(): CreateNotificationDTO
    {
        return new CreateNotificationDTO(
            title: $this->input('title'),
            message: $this->input('message'),
            user_email: $this->input('send_to_employee') ? $this->input('user_email') : null,
            send_to_all: !$this->input('send_to_employee', false),
        );
    }
}
