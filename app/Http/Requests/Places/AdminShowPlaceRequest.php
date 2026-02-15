<?php
namespace App\Http\Requests\Places;

use Illuminate\Foundation\Http\FormRequest;

class AdminShowPlaceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'place' => 'required|integer|exists:places,id',
        ];
    }
}

