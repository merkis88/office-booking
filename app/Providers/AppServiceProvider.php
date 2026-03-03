<?php

namespace App\Providers;

use App\Handlers\Auth\SendTemporaryPasswordHandler;
use App\Handlers\Auth\SendVerificationHandler;
use App\Handlers\Auth\VerifyEmailHandler;
use App\Handlers\Places\AdminArchivePlaceHandler;
use App\Handlers\Places\AdminDeletePhotoPlaceHandler;
use App\Handlers\Places\AdminStorePhotoPlaceHandler;
use Illuminate\Support\ServiceProvider;
use App\Handlers\Auth\LoginHandler;
use App\Handlers\Auth\RegisterHandler;
use App\Handlers\Auth\LogoutHandler;
use App\Handlers\Users\CreateUserHandler;
use App\Handlers\Users\UpdateUserHandler;
use App\Handlers\Users\UpdatePasswordHandler;
use App\Handlers\Reviews\CreateReviewHandler;
use App\Handlers\Reviews\UpdateReviewHandler;
use App\Handlers\Reviews\DeleteReviewHandler;
use App\Handlers\Reviews\FilterReviewHandler;
use App\Handlers\Notifications\CreateNotificationHandler;
use App\Handlers\Notifications\GetUserNotificationsHandler;
use App\Handlers\Notifications\MarkNotificationAsReadHandler;
use App\Handlers\Notifications\DeleteNotificationHandler;

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
        $this->app->singleton(CreateUserHandler::class);
        $this->app->singleton(UpdateUserHandler::class);
        $this->app->singleton(UpdatePasswordHandler::class);
        $this->app->singleton(CreateReviewHandler::class);
        $this->app->singleton(UpdateReviewHandler::class);
        $this->app->singleton(DeleteReviewHandler::class);
        $this->app->singleton(FilterReviewHandler::class);
        $this->app->singleton(AdminStorePhotoPlaceHandler::class);
        $this->app->singleton(AdminDeletePhotoPlaceHandler::class);
        $this->app->singleton(AdminArchivePlaceHandler::class);
        $this->app->singleton(SendVerificationHandler::class);
        $this->app->singleton(VerifyEmailHandler::class);
        $this->app->singleton(SendTemporaryPasswordHandler::class);
        $this->app->singleton(CreateNotificationHandler::class);
        $this->app->singleton(GetUserNotificationsHandler::class);
        $this->app->singleton(MarkNotificationAsReadHandler::class);
        $this->app->singleton(DeleteNotificationHandler::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
