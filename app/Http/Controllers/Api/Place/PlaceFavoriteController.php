<?php

namespace App\Http\Controllers\Api\Place;

use App\Handlers\Places\AddFavoritePlaceHandler;
use App\Handlers\Places\RemoveFavoritePlaceHandler;
use App\Http\Controllers\Controller;
use App\Models\Place;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class PlaceFavoriteController extends Controller
{
    public function store(Request $request, Place $place, AddFavoritePlaceHandler $handler): JsonResponse
    {
        $add_favorite_place = $handler->handle($request->user(), $place);

        return response()->json(['data' => $add_favorite_place]);
    }

    public function remove(Request $request, Place $place, RemoveFavoritePlaceHandler $handler): JsonResponse
    {
        $remove_favorite_place = $handler->handle($request->user(), $place);

        return response()->json(['data' => $remove_favorite_place]);
    }
}
