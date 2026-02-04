<?php
namespace  App\Handlers\Users;

use App\DTO\Users\UpdateUserDTO;
use App\Models\User;
use Illuminate\Validation\Rule;

class UpdateUserHandler
{
    /**
     * Обновление данных пользователя
     *
     * @param User $user
     * @param UpdateUserDTO $dto
     * @return User
     */
    public function handle(User $user, UpdateUserDTO $dto): User
    {
        $data = array_filter($dto->toArray(), fn($value) => $value !== null);
        if (isset($data['email']) && $data['email'] !== $user->email) {
            $data['email'] = strtolower($data['email']);
        }

        $user->update($data);

        return $user->fresh();
    }
}
