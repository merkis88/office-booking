<?php
namespace App\Handlers\Services;

use App\DTO\Services\UpdateServiceStatusDTO;
use App\Models\Service;
use Illuminate\Validation\ValidationException;

class UpdateServiceStatusHandler
{
    public function handle(Service $service, UpdateServiceStatusDTO $dto): Service
    {
        if($service->isCompleted()){
            throw ValidationException::withMessages([
                'status' => ['Нельзя изменить статус выполненой заявки']
            ]);
        }
        $service->update([
            'status' => $dto->status
        ]);
        if ($dto->status === 'completed') {
            $service->markAsCompleted();
        }

        return $service->fresh();
    }
}
