<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    use HasFactory;

    protected $table = 'bookings';

    protected $fillable = [
        'place_id',
        'created_by',
        'organization_id',
        'user_id',
        'guest_name',
        'parking_place_id',
        'start_time',
        'end_time',
        'status',
        'pass_type',
        'price',
    ];

    protected $casts = [
        'start_time' => 'datetime',
        'end_time'   => 'datetime',
    ];

    public function place()
    {
        return $this->belongsTo(Place::class, 'place_id', 'id');
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by', 'id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    public function organization()
    {
        return $this->belongsTo(Organization::class, 'organization_id', 'id');
    }

    public function parkingPlace()
    {
        return $this->belongsTo(Parking_place::class, 'parking_place_id', 'id');
    }
}
