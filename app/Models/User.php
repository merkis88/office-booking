<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'role_id',
        'first_name',
        'last_name',
        'patronymic',
        'email',
        'password',
        'photo',
        'post',
        'company',
        'is_verified',
        'verification_code',
        'verification_code_expires_at',
    ];

    public function role()
    {
        return $this->belongsTo(Role::class, 'role_id', 'id');
    }

//    public function createdBy()
//    {
//        return $this->hasMany(Booking::class, 'created_by');
//    }
//
//    public function userId()
//    {
//        return $this->hasMany(Booking::class, 'user_id');
//    }
    public function bookings()
    {
        return $this->hasMany(Booking::class, 'user_id');
    }

    public function createdBookings()
    {
        return $this->hasMany(Booking::class, 'created_by');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class, 'user_id');
    }
    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'verification_code',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_verified' => 'boolean',
            'verification_code_expires_at' => 'datetime',
        ];
    }

    public function generateVerificationCode(): string
    {
        $code = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $this->verification_code = $code;
        $this->verification_code_expires_at = Carbon::now()->addMinutes(30);
        $this->save();

        return $code;
    }

    public function verifyCode(string $code): bool
    {
        if($this->verification_code_expires_at && Carbon::now()->gt($this->verification_code_expires_at)){
            return false;
        }
        return $this->verification_code === $code;
    }
    public function markAsVerified(): void
    {
        $this->is_verified = true;
        $this->email_verified_at = Carbon::now();
        $this->verification_code = null;
        $this->verification_code_expires_at = null;
        $this->save();
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class, 'user_id');
    }

    public function createdNotifications()
    {
        return $this->hasMany(Notification::class, 'created_by');
    }

    public function unreadNotifications()
    {
        return $this->notifications()->unread();
    }
    public function services()
    {
        return $this->hasMany(Service::class);
    }

    public function blocks()
    {
        return $this->hasMany(UserBlock::class, 'user_id');
    }

    public function blockedUsers()
    {
        return $this->hasMany(UserBlock::class, 'blocked_by');
    }

    public function favoritePlaces(): BelongsToMany
    {
        return $this->belongsToMany(Place::class, 'favorite_places');
    }

}
