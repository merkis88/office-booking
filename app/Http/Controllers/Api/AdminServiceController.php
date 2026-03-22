<?php

namespace App\Http\Controllers\Api;

use App\Handlers\Services\GetCompletedServicesHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Services\UpdateServiceStatusRequest;
use App\Handlers\Services\GetAllServicesHandler;
use App\Handlers\Services\UpdateServiceStatusHandler;
use App\Http\Resources\ServiceResource;
use App\Models\Service;
use App\Models\ServiceType;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class AdminServiceController extends Controller
{
    public function __construct(
        private GetAllServicesHandler $getAllServicesHandler,
        private GetCompletedServicesHandler $getCompletedServicesHandler,
        private UpdateServiceStatusHandler $updateServiceStatusHandler
    )
    {

    }
    public function index(): JsonResponse
    {
        $services = $this->getAllServicesHandler->handle(
            request()->input('status'),
            request()->input('per_page', 6)
        );

        return response()->json([
            'success' => true,
            'data' => ServiceResource::collection($services),
            'meta' => [
                'current_page' => $services->currentPage(),
                'last_page' => $services->lastPage(),
                'per_page' => $services->perPage(),
                'total' => $services->total(),
            ]
        ]);
    }

    public function completed(): JsonResponse
    {
        $services = $this->getCompletedServicesHandler->handle(request()->input('per_page', 6));
        return response()->json([
            'success' => true,
            'data' => ServiceResource::collection($services),
            'meta' => [
                'current_page' => $services->currentPage(),
                'last_page' => $services->lastPage(),
                'per_page' => $services->perPage(),
                'total' => $services->total(),
            ]
        ]);
    }
    public function updateStatus(Service $service, UpdateServiceStatusRequest $request): JsonResponse
    {
        try {
            $updatedService = $this->updateServiceStatusHandler->handle(
                $service,
                $request->toDTO()
            );

            return response()->json([
                'success' => true,
                'message' => 'Статус заявки обновлен',
                'data' => new ServiceResource($updatedService->load(['user', 'booking.place', 'serviceType']))
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при обновлении статуса',
                'errors' => $e->errors()
            ], 422);
        }
    }
    public function getServiceTypes(): JsonResponse
    {
        $types = ServiceType::all();

        return response()->json([
            'success' => true,
            'data' => $types
        ]);
    }
}
