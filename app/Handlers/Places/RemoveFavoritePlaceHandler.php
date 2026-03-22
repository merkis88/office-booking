<?php

namespace App\Handlers\Places;

use App\Models\FavoritePlace;
use App\Models\Place;
use App\Models\User;

final class RemoveFavoritePlaceHandler
{
    public function handle(User $user, Place $place): Place
    {
        FavoritePlace::query()
            ->where('user_id', $user->id)
            ->where('place_id', $place->id)
            ->delete();

        $place->setAttribute('is_favorite', true);

        return $place;
    }
}
