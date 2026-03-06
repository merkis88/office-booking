<?php
namespace App\Handlers\Services;

use App\Models\Service;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class GetAllServicesHandler
{
    public function handle(?string $status = null, ?int $perPage = 6): LengthAwarePaginator
    {
        $query = Service::with(['user', 'booking.place', 'serviceType'])->active();

        if ($status) {
            $query->where('status', $status);
        }

        return $query->orderBy('created_at', 'desc')->paginate($perPage);
    }
}
