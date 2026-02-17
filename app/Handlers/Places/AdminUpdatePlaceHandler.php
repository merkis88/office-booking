<?php
namespace App\Handlers\Places;

use App\DTO\Places\UpdatePlaceDTO;
use App\Models\Place;
use Illuminate\Validation\ValidationException;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class AdminUpdatePlaceHandler
{
    const PHOTO_DIRECTORY = 'public/places';
    public function handle(Place $place, UpdatePlaceDTO $dto, ?UploadedFile $newPhoto = null, bool $removePhoto = false): Place
    {
        $data = array_filter($dto->toArray(), fn ($value) => $value !== null);

        if ($newPhoto) {
            $data['photo'] = $this->uploadNewPhoto($newPhoto, $place->photo);
        } elseif ($removePhoto && $place->photo) {
            $this->deletePhoto($place->photo);
            $data['photo'] = null;
        }

        if (empty($data)) {
            throw ValidationException::withMessages([
                'data' => ['Нет данных для обновления']
            ]);
        }
        $place->update($data);
        return $place->fresh();
    }
    private function uploadNewPhoto(UploadedFile $file, ?string $oldPhoto): string
    {
        if ($file->getSize() > 5 * 1024 * 1024) {
            throw ValidationException::withMessages([
                'photo' => ['Размер файла не должен превышать 5MB']
            ]);
        }

        $extension = strtolower($file->getClientOriginalExtension());
        if (!in_array($extension, ['jpeg', 'png', 'jpg', 'gif'])) {
            throw ValidationException::withMessages([
                'photo' => ['Допустимые форматы jpeg, png, jpg, gif']
            ]);
        }

        if ($oldPhoto) {
            $this->deletePhoto($oldPhoto);
        }

        $filename = time() . '_' . uniqid() . '.' . $extension;
        $path = $file->storeAs(self::PHOTO_DIRECTORY, $filename);

        if (!$path) {
            throw new \RuntimeException('Не удалось сохранить фото');
        }

        return str_replace('public/', '', $path);
    }
    private function deletePhoto(string $photoPath): void
    {
        $fullPath = self::PHOTO_DIRECTORY . '/' . $photoPath;
        if (Storage::exists($fullPath)) {
            Storage::delete($fullPath);
        }
    }
}
