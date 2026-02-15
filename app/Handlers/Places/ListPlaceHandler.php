<?php
namespace App\Handlers\Places;

use App\Models\Place;
use Illuminate\Database\Eloquent\Collection;

class ListPlaceHandler
{
    public function handle(?string $type = null): Collection
    {
        $query = Place::query()
            ->where('is_active', true)
            ->whereDoesntHave('booking', function ($query) {
            $query->where('status', 'approved')
                ->where('start_time', '<=', now())
                ->where('end_time', '>=', now());
        })->orderBy('created_at', 'desc');

        if($type !== null) {
            $query->where('type', $type);
        }

        return $query->get();
    }
}
