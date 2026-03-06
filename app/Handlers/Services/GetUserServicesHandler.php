<?php
namespace App\Handlers\Services;

use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class GetUserServicesHandler
{
    public function handle(User $user, ?int $perPage = 6): LengthAwarePaginator
    {
        return $user->services()->with(['booking.place', 'serviceType'])->orderBy('created_at', 'desc')->paginate($perPage);
    }
}
