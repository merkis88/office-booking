<?php
namespace App\Handlers\Places;

use App\Models\Place;

class ShowPlaceHandler
{
    public function handle(Place $place): Place
    {
        return $place;
    }
}
