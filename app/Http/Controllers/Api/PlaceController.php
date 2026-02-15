<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Handlers\Places\ListPlaceHandler;
use App\Handlers\Places\ShowPlaceHandler;
use App\Http\Requests\Places\IndexPlaceRequest;
use App\Http\Requests\Places\ShowPlaceRequest;
use App\Http\Resources\PlaceResource;
use App\Models\Place;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PlaceController extends Controller
{
    public function __construct(
        private ListPlaceHandler $listPlaceHandler,
        private ShowPlaceHandler $showPlaceHandler,
    )
    {

    }

    public function index(IndexPlaceRequest $request): JsonResponse
    {
        $type = $request->input('type');
        $places = $this->listPlaceHandler->handle($type);

        return response()->json([
            'success' => true,
            'data' => PlaceResource::collection($places),
        ]);
    }
    public function show(ShowPlaceRequest $request, Place $place): JsonResponse
    {
        if(!$place->is_active){
            return response()->json([
                'success' => false,
                'message' => 'Помещение не доступно для аренды'
            ],404);
        }
        $place = $this->showPlaceHandler->handle($place);
        return response()->json([
            'success' => true,
            'data' => new PlaceResource($place),
        ]);
    }
}
