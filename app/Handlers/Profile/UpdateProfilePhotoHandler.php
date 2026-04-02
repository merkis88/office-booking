<?php

namespace App\Handlers\Profile;

use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

final class UpdateProfilePhotoHandler
{
    public function handle(User $user, UploadedFile $photo): array
    {
        if (! $photo->isValid()) {
            throw ValidationException::withMessages([
                'photo' => ['Файл повреждён или не был загружен'],
            ]);
        }

        if ($user->photo) {
            Storage::disk('public')->delete($user->photo);
        }

        $path = $photo->store('profile-photos', 'public');

        $user->photo = $path;
        $user->save();

        return [
            'id' => $user->id,
            'role_id' => $user->role_id,
            'photo' => $user->photo,
            'photo_url' => Storage::disk('public')->url($user->photo),
            'updated_at' => $user->updated_at,
        ];
    }
}
