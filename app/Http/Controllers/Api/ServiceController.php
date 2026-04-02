<?php

namespace App\Http\Controllers\Api;

use App\Handlers\Services\CreateServiceHandler;
use App\Handlers\Services\GetUserServicesHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Services\CreateServiceRequest;
use App\Http\Resources\ServiceResource;
use Illuminate\Http\JsonResponse;

class ServiceController extends Controller
{
    public function __construct(
        private CreateServiceHandler $createServiceHandler,
        private GetUserServicesHandler $getUserServicesHandler,
    ) {}

    public function index(): JsonResponse
    {
        $services = $this->getUserServicesHandler->handle(request()->user(), request()->input('per_page', 6));

        return response()->json([
            'data' => ServiceResource::collection($services),
            'meta' => [
                'current_page' => $services->currentPage(),
                'last_page' => $services->lastPage(),
                'per_page' => $services->perPage(),
                'total' => $services->total(),
            ],
        ]);
    }

    public function store(CreateServiceRequest $request): JsonResponse
    {
        $service = $this->createServiceHandler->handle(
            $request->toDTO(),
            $request->user()
        );

        return response()->json([
            'message' => 'Заявка успешно создана',
            'data' => new ServiceResource($service->load(['booking.place', 'serviceType'])),
        ], 201);
    }

    public function getUserBookings(): JsonResponse
    {
        $user = request()->user();

        $bookings = $user->bookings()->where('status', 'active')->with('place')->get()
            ->map(function ($booking) {
                return [
                    'id' => $booking->id,
                    'place_name' => $booking->place->name,
                    'place_number' => $booking->place->number_place,
                    'date' => $booking->start_time->format('d.m.Y'),
                    'time' => $booking->start_time->format('H:i').' - '.$booking->end_time->format('H:i'),
                ];
            });

        return response()->json([
            'data' => $bookings,
        ]);
    }
}
