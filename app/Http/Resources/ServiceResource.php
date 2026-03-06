<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ServiceResource extends JsonResource
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
                 'user' => new UserResource($this->whenLoaded('user')),
                 'booking' => $this->whenLoaded('booking', function() {
                     return [
                         'id' => $this->booking->id,
                         'place' => new PlaceResource($this->booking->place),
                         'start_time' => $this->booking->start_time->format('d.m.Y H:i'),
                         'end_time' => $this->booking->end_time->format('d.m.Y H:i'),
                     ];
                 }),
                 'place' => new PlaceResource($this->whenLoaded('place')),
                 'service_type' => [
                     'id' => $this->serviceType->id,
                     'name' => $this->serviceType->name,
                 ],
                 'service_date' => $this->service_date->format('d.m.Y'),
                 'service_time' => $this->service_time->format('H:i'),
                 'comment' => $this->comment,
                 'status' => $this->status,
                 'status_name' => match($this->status) {
                     'pending' => 'В ожидании',
                     'in_progress' => 'В работе',
                     'completed' => 'Выполнено',
                     'rejected' => 'Отказано',
                     default => $this->status,
                 },
                 'created_at' => $this->created_at->format('d.m.Y H:i'),
                 'updated_at' => $this->updated_at->format('d.m.Y H:i'),
        ];
    }
}
