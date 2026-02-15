<?php
namespace App\Handlers\Places;

use App\Models\Place;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AdminStorePhotoPlaceHandler{
    const PHOTO_DIRECTORY = 'public/places';

    public function handle(Place $place, UploadedFile $file): Place
    {
        $this->validateFile($file);

        if($place->photo){
            $this->deleteOldPhoto($place->photo);
        }

        $filename = $this->generateFilename($file);
        $path = $file->storeAs(self::PHOTO_DIRECTORY, $filename);
        if(!$path) {
            throw new \RuntimeException('Не удалось сохранить файл');
        }
        $place->update([
            'photo' => str_replace('public/', '', $path)
        ]);
        return $place->fresh();
    }

    public function validateFile(UploadedFile $file): void
    {
        $errors = [];
        if($file->getSize()>5 * 1024 * 1024){
            $errors['photo'] = ['Размер файла не должен превышать 5МБ'];
        }
        $extension = strtolower($file->getClientOriginalExtension());
        if(!in_array($extension, ['jpg', 'jpeg', 'png', 'gif'])){
            $errors['photo'] = ['Допустимые форматы jpg jpeg png gif'];
        }

        if (!empty($errors)) {
            throw ValidationException::withMessages($errors);
        }
    }
    private function deleteOldPhoto(string $photoPath): void
    {
        $fullPath = self::PHOTO_DIRECTORY . '/' . $photoPath;
        if (Storage::exists($fullPath)) {
            Storage::delete($fullPath);
        }
    }
    private function generateFilename(UploadedFile $file): string
    {
        return time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
    }
}
