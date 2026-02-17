<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Places\AdminIndexPlaceRequest;
use App\Http\Requests\Places\AdminShowPlaceRequest;
use App\Http\Requests\Places\AdminStorePlaceRequest;
use App\Http\Requests\Places\AdminUpdatePlaceRequest;
use App\Http\Requests\Places\AdminDeletePlaceRequest;
use App\Http\Requests\Places\AdminStorePhotoPlaceRequest;
use App\Handlers\Places\AdminCreatePlaceHandler;
use App\Handlers\Places\AdminUpdatePlaceHandler;
use App\Handlers\Places\AdminDeletePlaceHandler;
use App\Http\Resources\PlaceResource;
use App\Models\Place;
use App\Handlers\Places\AdminStorePhotoPlaceHandler;
use App\Handlers\Places\AdminDeletePhotoPlaceHandler;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class AdminPlaceController extends Controller
{
    public function __construct(
        private AdminCreatePlaceHandler $createPlaceHandler,
        private AdminUpdatePlaceHandler $updatePlaceHandler,
        private AdminDeletePlaceHandler $deletePlaceHandler,
        private AdminStorePhotoPlaceHandler $storePhotoPlaceHandler,
        private AdminDeletePhotoPlaceHandler $deletePhotoPlaceHandler,
    )
    {

    }

    public function index(AdminIndexPlaceRequest $request): JsonResponse
    {
        $query = Place::query();
        if($request->filled('type')){
            $query->where('type', $request->type);
        }
        if($request->filled('is_active')){
            $query->where('is_active', $request->boolean('is_active'));
        }

        $sortBy = $request->input('sortBy', 'created_at');
        $sortDirection = $request->input('sortDirection', 'desc');
        $query->orderBy($sortBy, $sortDirection);

        $perPage = $request->input('perPage', 6);
        $places = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => PlaceResource::collection($places),
            'meta' => [
                'current_page' => $places->currentPage(),
                'last_page' => $places->lastPage(),
                'per_page' => $places->perPage(),
                'total' => $places->total(),
            ]
        ]);
    }

    public function store(AdminStorePlaceRequest $request): JsonResponse
    {
        try{
            $dto = $request->toDTO();
            $photoFile = $request->hasFile('photo') ? $request->file('photo') : null;
            $place = $this->createPlaceHandler->handle($dto, $photoFile);
            return response()->json([
                'success' => true,
                'message' => 'Помещение успешно создано',
                'data' => new PlaceResource($place),
            ],201);
        }
        catch (ValidationException $e){
            return response()->json([
                'success' => false,
                'message' => 'Ошибка валидации',
                'errors' => $e->errors()
            ],422);
        }
    }

    public function show(AdminShowPlaceRequest $request,Place $place): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => new PlaceResource($place),
        ]);
    }
    public function update(AdminUpdatePlaceRequest $request,Place $place): JsonResponse
    {
        try{
            $dto = $request->toDTO();
            $photoFile = $request->hasFile('photo') ? $request->file('photo') : null;
            $removePhoto = $request->input('remove_photo') === 'true' || $request->input('remove_photo') === true;
            $updatedPlace = $this->updatePlaceHandler->handle($place, $dto, $photoFile, $removePhoto);
            return response()->json([
                'success' => true,
                'message' => 'Помещение успешно обновлено',
                'data' => new PlaceResource($updatedPlace),
            ]);
        }
        catch (ValidationException $e){
            return response()->json([
                'success' => false,
                'message' => 'Ошибка валидации',
                'errors' => $e->errors()
            ],422);
        }
    }

    public function destroy(AdminDeletePlaceRequest $request,Place $place): JsonResponse
    {
        try{
            $this->deletePlaceHandler->handle($place);

            return response()->json([
                'success' => true,
                'message' => 'Помещение успешно удалено'
            ]);
        }
        catch (ValidationException $e){
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при удалении',
                'errors' => $e->errors()
            ],422);
        }
    }
    public function storePhoto(Place $place, AdminStorePhotoPlaceRequest $request): JsonResponse
    {
        try {
            $updatedPlace = $this->storePhotoPlaceHandler->handle(
                $place,
                $request->file('photo')
            );

            return response()->json([
                'success' => true,
                'message' => 'Фото успешно загружено',
                'data' => new PlaceResource($updatedPlace),
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Ошибка валидации',
                'errors' => $e->errors()
            ], 422);
        }
    }
    public function deletePhoto(Place $place): JsonResponse
    {
        try {
            $updatedPlace = $this->deletePhotoPlaceHandler->handle($place);

            return response()->json([
                'success' => true,
                'message' => 'Фото успешно удалено',
                'data' => new PlaceResource($updatedPlace),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при удалении фото',
            ], 500);
        }
    }

}
