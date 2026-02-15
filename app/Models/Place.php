<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Place extends Model
{
    use HasFactory;
    protected $table = 'places';
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
}
