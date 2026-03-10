<?php
namespace App\Handlers\Services;

use App\DTO\Services\CreateServiceTypeDTO;
use App\Models\ServiceType;

class CreateServiceTypeHandler
{
    public function handle(CreateServiceTypeDTO $dto): ServiceType
    {
        return ServiceType::create([
            'name' => $dto->name,
        ]);
    }
}
