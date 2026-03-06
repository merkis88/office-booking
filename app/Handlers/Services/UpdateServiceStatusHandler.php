<?php
namespace App\Handlers\Services;

use App\DTO\Services\UpdateServiceStatusDTO;
use App\Models\Service;

class UpdateServiceStatusHandler
{
    public function handle(Service $service, UpdateServiceStatusDTO $dto): Service
    {
        $service->update([
            'status' => $dto->status
        ]);

        return $service->fresh();
    }
}
