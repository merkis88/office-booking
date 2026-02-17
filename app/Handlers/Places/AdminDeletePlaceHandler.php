<?php
namespace App\Handlers\Places;

use App\Models\Place;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AdminDeletePlaceHandler
{
    const PHOTO_DIRECTORY = 'public/places';
    public function handle(Place $place): void
    {
        if($place->booking()->whereIn('status', ['pending', 'approved'])->exists()){
            throw ValidationException::withMessages([
                'place' => ['Нельзя удалить помещение с активной арендой']
            ]);
        }
        if ($place->photo) {
            $fullPath = self::PHOTO_DIRECTORY . '/' . $place->photo;
            if (Storage::exists($fullPath)) {
                Storage::delete($fullPath);
            }
        }
        $place->delete();
    }
}
