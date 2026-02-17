<?php
namespace App\Handlers\Places;

use App\Models\Place;
use Illuminate\Support\Facades\Storage;

class AdminDeletePhotoPlaceHandler
{
    const PHOTO_DIRECTORY = 'public/places';

    public function handle(Place $place): Place
    {
        if($place->photo){
            $fullPath = self::PHOTO_DIRECTORY . '/' . $place->photo;
            if(Storage::exists($fullPath)){
                Storage::delete($fullPath);
            }
            $place->update(['photo' => null]);
        }
        return $place->fresh();
    }
}
