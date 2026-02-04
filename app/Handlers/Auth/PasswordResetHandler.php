<?php
namespace App\Handlers\Auth;

use App\DTO\Auth\PasswordResetDTO;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Auth\Events\PasswordReset as PasswordResetEvent;

class PasswordResetHandler
{
    /**
     * Обработка сброса пароля
     *
     * @param PasswordResetDTO $dto
     * @return string
     */
    public function handle(PasswordResetDTO $dto): string
    {
        $status = Password::reset(
          $dto->toArray(),
          function ($user, $password) {
              $user->forceFill([
                  'password' => Hash::make($password),
              ])->setRememberToken(Str::random(60));

              $user->save();

              event(new PasswordResetEvent($user));
          }
        );
        return $status;
    }
}
