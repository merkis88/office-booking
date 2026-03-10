<?php

namespace App\Http\Controllers\Api;

use App\DTO\Services\CreateServiceTypeDTO;
use App\Handlers\Services\CreateServiceTypeHandler;
use App\Handlers\Services\DeleteServiceTypeHandler;
use App\Handlers\Services\GetServiceTypeHandler;
use App\Handlers\Services\UpdateServiceTypeHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Services\CreateServiceTypeRequest;
use App\Http\Requests\Services\UpdateServiceTypeRequest;
use App\Models\ServiceType;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Nette\Schema\ValidationException;

class AdminServiceTypeController extends Controller
{
    public function __construct(
        private CreateServiceTypeHandler $createServiceTypeHandler,
        private UpdateServiceTypeHandler $updateServiceTypeHandler,
        private DeleteServiceTypeHandler $deleteServiceTypeHandler,
        private GetServiceTypeHandler $getServiceTypesHandler,
    )
    {

    }

    public function index(): JsonResponse
    {
        $serviceTypes = $this->getServiceTypesHandler->handle();
        return response()->json([
            'success' => true,
            'data' => $serviceTypes
        ]);
    }

    public function store(CreateServiceTypeRequest $request): JsonResponse
    {
        try{
            $serviceType = $this->createServiceTypeHandler->handle($request->toDTO());
            return response()->json([
                'success' => true,
                'message' => 'Тип заявки создан',
                'data' => $serviceType
            ],201);
        } catch (ValidationException $e){
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при создании типа заявки',
                'errors' => $e->errors()
            ],422);
        }
    }

    public function show(ServiceType $serviceType): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $serviceType
        ]);
    }
    public function update(UpdateServiceTypeRequest $request, ServiceType $serviceType): JsonResponse
    {
        try{
            $updatedServiceType = $this->updateServiceTypeHandler->handle($serviceType, $request->toDTO());
            return response()->json([
                'success' => true,
                'message' => 'Тип Заявки обновлен',
                'data' => $updatedServiceType
            ]);
        } catch (ValidationException $e){
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при обновлении',
                'errors' => $e->errors()
            ],422);
        }
    }

    public function destroy(ServiceType $serviceType): JsonResponse
    {
        try{
            $this->deleteServiceTypeHandler->handle($serviceType);
            return response()->json([
                'success' => true,
                'message' => 'Тип заявки удален',
            ]);
        }catch(ValidationException $e){
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при удалении',
                'errors' => $e->errors()
            ],422);
        }
    }
}
