<?php
namespace App\Handlers\Places;

use App\DTO\Places\FilterPlaceDTO;
use App\Models\Place;
use Illuminate\Database\Eloquent\Collection;
use App\Services\Places\PlaceAvailabilityService;

class FilterPlaceHandler
{
    public function __construct(
        private PlaceAvailabilityService $availabilityService
    ) {}
    public function handle(Collection $places, FilterPlaceDTO $dto): Collection
    {
        if($dto->min_price === null && $dto->max_price === null){
            return $places;
        }
        $filtered = $places->filter(function (Place $place) use ($dto) {
            if($dto->min_price !== null && $place->price < $dto->min_price){
                return false;
            }
            if($dto->max_price !== null && $place->price > $dto->max_price){
                return false;
            }
            return true;
        });
        if ($dto->date !== null) {
            $filtered = $filtered->filter(function (Place $place) use ($dto) {
                return $this->availabilityService->hasAvailableSlots($place, $dto->date);
            });
        }
        return new Collection($filtered->values()->all());
    }

    public function getPriceRange(Collection $places): array
    {
        if($places->isEmpty()){
            return [
                'min_price' => 0,
                'max_price' => 0,
            ];
        }
        return [
            'min_price' => (float) $places->min('price'),
            'max_price' => (float) $places->max('price'),
        ];

    }
}

