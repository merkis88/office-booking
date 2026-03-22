<?php

namespace App\Handlers\Places;

use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

final class GetFavoritePlacesHandler
{
    public function handle(User $user): Collection
    {
        return $user->favoritePlaces()->get()->each(function ($place) {
            $place->setAttribute('is_favorite', true);
        });
    }
}
