<?php
namespace App\Handlers\Auth;

use App\DTO\Auth\RegisterDTO;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class RegisterHandler
{
    public function __construct(
        private SendVerificationHandler $sendVerificationHandler
    )
    {

    }
    public function handle(RegisterDTO $dto): array
    {
        return DB::transaction(function () use ($dto) {
           $user = User::create([
               'first_name' => $dto->first_name,
               'last_name' => $dto->last_name,
               'patronymic' => $dto->patronymic,
               'email' => $dto->email,
               'password' => Hash::make($dto->password),
               'photo' => $dto->photo,
               'post' => $dto->post,
               'company' => $dto->company,
               'role_id' => $dto->role_id ?? 2,
               'is_verified' => false,
           ]);
           $this->sendVerificationHandler->handle($user);
            return [
                'user' => $user,
                'message' => 'На ваш email отправлен код подтверждения'
            ];
        });
    }
}
