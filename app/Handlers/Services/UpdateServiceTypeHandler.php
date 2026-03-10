<?php
namespace App\Handlers\Services;

use App\DTO\Services\UpdateServiceTypeDTO;
use App\Models\ServiceType;

class UpdateServiceTypeHandler
{
    public function handle(ServiceType $serviceType, UpdateServiceTypeDTO $dto): ServiceType
    {
        if($dto->name !==null){
            $serviceType->update([
                'name' => $dto->name
            ]);
        }
        return $serviceType->fresh();
    }
}
