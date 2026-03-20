<?php

namespace App\Http\Controllers\Api\Place;

use App\Handlers\Places\GetFavoritePlacesHandler;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class FavoritePlaceListController extends Controller
{
    public function getPlace(Request $request, GetFavoritePlacesHandler $handler): JsonResponse
    {
        $places = $handler->handle($request->user());

        return response()->json(['data' => $places], 200);
    }
}
