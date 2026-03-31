<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class PlaceResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'type' => $this->type,
            'type_name' => match($this->type) {
                'office' => 'Офис',
                'coworking' => 'Коворкинг',
                'meeting' => 'Переговорная',
                default => $this->type,
            },
            'capacity' => $this->capacity,
            'number_place' => $this->number_place,
            'photo_url' => $this->photo ? asset('storage/' . $this->photo) : null,
            'photo_path' => $this->photo,
            'price' => $this->price,
            'description' => $this->description,
            'is_active' => $this->is_active,
            'is_favorite' => (bool) ($this->is_favorite ?? false),
            'created_at' => $this->created_at?->format('d.m.Y H:i'),
            'updated_at' => $this->updated_at?->format('d.m.Y H:i'),
        ];
    }


}
