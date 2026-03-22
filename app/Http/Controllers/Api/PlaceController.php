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
use App\Services\Places\PlaceAvailabilityService;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PlaceController extends Controller
{
    public function __construct(
        private ListPlaceHandler $listPlaceHandler,
        private ShowPlaceHandler $showPlaceHandler,
        private FilterPlaceHandler $filterPlaceHandler,
        private PlaceAvailabilityService $availabilityService,
    )
    {

    }

    public function index(IndexPlaceRequest $request,FilterPlaceRequest $filterRequest): JsonResponse
    {
        $type = $request->input('type');
        $places = $this->listPlaceHandler->handle($type);
        $priceRange = $this->filterPlaceHandler->getPriceRange($places);
        $filterDto = $filterRequest->toDTO();
        if ($filterDto->date === null) {
            $filterDto->date = CarbonImmutable::today();
        }
        $filteredPlaces = $this->filterPlaceHandler->handle($places, $filterDto);

        $response = [
            'success' => true,
            'filters' => [
                'price_range' => $priceRange,
                'current' => [
                    'min_price' => $filterDto->min_price ?? $priceRange['min_price'],
                    'max_price' => $filterDto->max_price ?? $priceRange['max_price'],
                    'date' => $filterDto->date->format('Y-m-d'),
                ]
            ]
        ];
        $data = [];
        foreach ($filteredPlaces as $place) {
            $placeResource = new PlaceResource($place);
            $placeArray = $placeResource->toArray($request);

            $placeArray['available_slots'] = $this->availabilityService->getAvailableSlots($place, $filterDto->date);
            $data[] = $placeArray;
        }

        $response['data'] = $data;

        return response()->json($response);
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
        $date = $request->has('date') ? CarbonImmutable::parse($request->input('date')) : CarbonImmutable::today();
        $placeResource = new PlaceResource($place);
        $placeArray = $placeResource->toArray($request);


        $placeArray['available_slots'] = $this->availabilityService->getAvailableSlots($place, $date);
        $response = [
            'success' => true,
            'data' => $placeArray,
            'availability' => [
                'date' => $date->format('Y-m-d'),
            ]
        ];
        return response()->json($response);
    }
}
