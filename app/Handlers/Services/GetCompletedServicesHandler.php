<?php
namespace App\Handlers\Services;

use App\Models\Service;
use Carbon\Carbon;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Log;

class GetCompletedServicesHandler
{
    public function handle(?string $status = null, ?int $perPage = 6): LengthAwarePaginator
    {
        $trash = Carbon::now()->subDays(3);
        $deletedCount = Service::where('status', 'completed')->where('completed_at', '<=', $trash)->delete();
        if($deletedCount > 0){
            Log::info("автоматически удалено {$deletedCount} старых заявок");
        }
        $query = Service::with(['user', 'booking.place', 'serviceType'])->completed();
        return $query->orderBy('completed_at', 'desc')->paginate($perPage);
    }
}
