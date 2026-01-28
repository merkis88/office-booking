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
        'price',
        'start_time',
        'end_time',
        'status',
        'pass_type'
    ];

    public function organization()
    {
        return $this->belongsTo(Organization::class, 'organization_id', 'id');
    }

    public function place()
    {
        return $this->belongsTo(Place::class, 'place_id', 'id');
    }
}
