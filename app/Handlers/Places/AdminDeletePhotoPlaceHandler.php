<?php
namespace App\Handlers\Places;

use App\Models\Place;
use Illuminate\Support\Facades\Storage;

class AdminDeletePhotoPlaceHandler
{
    const PHOTO_DIRECTORY = 'public/places';

    public function handle(Place $place): Place
    {
        if ($place->photo) {
            try {
                if (Storage::disk('public')->exists($place->photo)) {
                    Storage::disk('public')->delete($place->photo);
                }

                $place->update(['photo' => null]);
            } catch (\Exception $e) {
                throw $e;
            }
        }

        return $place->fresh();
    }
}
