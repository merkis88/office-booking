<?php
namespace App\Handlers\Places;

use App\Models\Place;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class AdminArchivePlaceHandler
{
    public function archive(Place $place , bool $force = false): Place
    {
        if ($place->is_active == 0) {
            throw ValidationException::withMessages([
                'place' => ['Помещение "' . $place->name . '" уже находится в архиве']
            ]);
        }

        $activeBookingsQuery = $place->booking()->whereIn('status', ['pending', 'approved']);
        $activeBookingsCount = $activeBookingsQuery->count();
        if ($activeBookingsCount > 0) {
            if($force){
                DB::transaction(function () use ($place, $activeBookingsQuery) {
                    $activeBookingsQuery->update(['status' => 'rejected']);
                    $place->update(['is_active' => false]);
                });
            } else {
                throw ValidationException::withMessages([
                    'place' => ["У помещения {$activeBookingsCount} активных помещений." . "Используйте force = 1 для принудительной архивации,все брони ьбудут отменены"]
                ]);
            }
        }
        else{
            $place->update(['is_active' => false]);
        }

        return $place->fresh();
    }

    public function restore(Place $place): Place
    {
        if ($place->is_active == 1) {
            throw ValidationException::withMessages([
                'place' => ['Помещение "' . $place->name . '" не находится в архиве']
            ]);
        }
        $place->update(['is_active' => true]);
        return $place->fresh();
    }
}
