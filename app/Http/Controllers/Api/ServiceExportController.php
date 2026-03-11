<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Services\ExportServiceRequest;
use App\Handlers\Services\ExportServiceHandler;
use App\Models\Service;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Validation\ValidationException;

class ServiceExportController extends Controller
{
    public function __construct(
        private ExportServiceHandler $exportHandler
    )
    {

    }

    public function export(Service $service, ExportServiceRequest $request): JsonResponse|Response
    {
        try{
            return $this->exportHandler->handle($service);
        }catch (ValidationException $e){
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при экспорте',
                'errors' => $e->errors()
            ],422);
        }catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при генерации PDF: ' . $e->getMessage()
            ], 500);
        }
    }
}
