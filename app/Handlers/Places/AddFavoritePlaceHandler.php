<?php

namespace App\Handlers\Places;

use App\Models\FavoritePlace;
use App\Models\Place;
use App\Models\User;

final class AddFavoritePlaceHandler
{
    public function handle(User $user, Place $place): Place
    {
        FavoritePlace::query()->firstOrCreate([
            'user_id' => $user->id,
            'place_id' => $place->id
        ]);

        return $place;

    }

}
