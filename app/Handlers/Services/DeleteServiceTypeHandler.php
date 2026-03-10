<?php
namespace App\Handlers\Services;

use App\Models\ServiceType;

class DeleteServiceTypeHandler
{
    public function handle(ServiceType $serviceType): void
    {
        $serviceType->delete();
    }
}
