<?php
namespace App\Handlers\Users;

use App\DTO\Users\UpdatePasswordDTO;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class UpdatePasswordHandler
{
    public function handle(User $user,UpdatePasswordDTO $dto): void
    {
        if(!Hash::check($dto->current_password, $user->password)){
            throw ValidationException::withMessages([
                'current_password' => ['Текущий пароль неверен!'],
            ]);
        }

        $user->update([
           'password' => Hash::make($dto->password),
        ]);
    }
}
