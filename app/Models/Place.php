<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Place extends Model
{
    use HasFactory;
    protected $table = 'places';
    protected $casts = [
        'is_favorite' => 'boolean',
    ];

    protected $fillable = [
        'name',
        'type',
        'capacity',
        'number_place',
        'is_active',
        'photo',
        'price',
        'description'
    ];

    public function service()
    {
        return $this->hasMany(Service::class, 'place_id');
    }

    public function booking()
    {
        return $this->hasMany(Booking::class, 'place_id');
    }

    public function favoredByUsers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'favorite_places', 'place_id', 'user_id');
    }
}
