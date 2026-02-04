<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Handlers\Auth\LoginHandler;
use App\Handlers\Auth\RegisterHandler;
use App\Handlers\Auth\LogoutHandler;
use App\Handlers\Auth\PasswordResetHandler;
use App\Handlers\Users\CreateUserHandler;
use App\Handlers\Users\UpdateUserHandler;
use App\Handlers\Users\UpdatePasswordHandler;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton(LoginHandler::class);
        $this->app->singleton(RegisterHandler::class);
        $this->app->singleton(LogoutHandler::class);
        $this->app->singleton(PasswordResetHandler::class);
        $this->app->singleton(CreateUserHandler::class);
        $this->app->singleton(UpdateUserHandler::class);
        $this->app->singleton(UpdatePasswordHandler::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
