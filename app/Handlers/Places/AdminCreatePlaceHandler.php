<?php
namespace App\Handlers\Places;

use App\DTO\Places\CreatePlaceDTO;
use App\Models\Place;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AdminCreatePlaceHandler
{
    const PHOTO_DIRECTORY = 'public/places';
    public function handle(CreatePlaceDTO $dto, ?UploadedFile $photoFile = null): Place
    {
        $photoPath = null;
        if ($photoFile) {
            $photoPath = $this->uploadPhoto($photoFile);
        }
        return Place::create([
            'name' => $dto->name,
            'type' => $dto->type,
            'capacity' => $dto->capacity,
            'number_place' => $dto->number_place,
            'is_active' => $dto->is_active,
            'price' => $dto->price,
            'photo' => $photoPath,
            'description' => $dto->description,
        ]);
    }
    private function uploadPhoto(UploadedFile $file): string
    {
        if ($file->getSize() > 5 * 1024 * 1024) {
            throw ValidationException::withMessages([
                'photo' => ['Размер файла не должен превышать 5MB']
            ]);
        }

        $extension = strtolower($file->getClientOriginalExtension());
        if (!in_array($extension, ['jpeg', 'png', 'jpg', 'gif'])) {
            throw ValidationException::withMessages([
                'photo' => ['Допустимые форматы: jpeg, png, jpg, gif']
            ]);
        }

        if (!Storage::exists(self::PHOTO_DIRECTORY)) {
            Storage::makeDirectory(self::PHOTO_DIRECTORY);
        }

        $filename = time() . '_' . uniqid() . '.' . $extension;
        $path = $file->storeAs(self::PHOTO_DIRECTORY, $filename);

        if (!$path) {
            throw new \RuntimeException('Не удалось сохранить фото');
        }

        return str_replace('public/', '', $path);
    }
}
