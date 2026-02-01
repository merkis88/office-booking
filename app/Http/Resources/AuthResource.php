<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AuthResource extends JsonResource
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
            'first_name' => $this->first_name,
            'patronymic'=>$this->patronymic,
            'email'=>$this->email,
            'password'=>$this->password,
            'role_id'=>$this->role_id,
            'post' => $this->post,
            'company' => $this->company,
            'photo' => $this->photo,
            'role' => new UserRoleResource($this->role)
        ];
    }
}
