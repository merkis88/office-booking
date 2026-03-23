<?php

namespace App\Http\Requests\Profile;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\UploadedFile;

final class UpdateProfilePhotoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        return [
            'photo' => ['required', 'file', 'image', 'mimes:jpg,jpeg,png,webp', 'max:5120',],
        ];
    }

    public function photo(): UploadedFile
    {
        $file = $this->file('photo');

        return $file;
    }
}
