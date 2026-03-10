<?php
namespace App\Handlers\Services;

use App\Models\ServiceType;
use Illuminate\Database\Eloquent\Collection;

class GetServiceTypeHandler
{
    public function handle(): Collection
    {
        $query = ServiceType::query();

        return $query->orderBy('name')->get();
    }
}
