<?php

namespace App\Http\Requests\Services;

use App\DTO\Services\ExportServiceDTO;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\ValidationException;

class ExportServiceRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        $user = $this->user();
        $service = $this->route('service');

        if(!$user || !$service) {
            return false;
        }
        if($user->role && $user->role->name === 'admin') return true;
        if((int) $service->user_id !== (int) $user->id) {
            throw ValidationException::withMessages([
                'service' => ['У вас геь доступа к этой заявке']
            ]);
        }
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
            //
        ];
    }
}
