<?php
namespace App\Http\Controllers\Api;

use App\Handlers\Places\FilterPlaceHandler;
use App\Http\Controllers\Controller;
use App\Handlers\Places\ListPlaceHandler;
use App\Handlers\Places\ShowPlaceHandler;
use App\Http\Requests\Places\FilterPlaceRequest;
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
        private FilterPlaceHandler $filterPlaceHandler,
    )
    {

    }

    public function index(IndexPlaceRequest $request,FilterPlaceRequest $filterRequest): JsonResponse
    {
        $type = $request->input('type');
        $places = $this->listPlaceHandler->handle($type);
        $priceRange = $this->filterPlaceHandler->getPriceRange($places);
        $filterDto = $filterRequest->toDTO();
        $filteredPlaces = $this->filterPlaceHandler->handle($places, $filterDto);

        return response()->json([
            'success' => true,
            'data' => PlaceResource::collection($filteredPlaces),
            'filters' => [
                'price_range' => $priceRange,
                'current' => [
                    'min_price' => $filterDto->min_price ?? $priceRange['min_price'],
                    'max_price' => $filterDto->max_price ?? $priceRange['max_price'],
                ]
            ]
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
