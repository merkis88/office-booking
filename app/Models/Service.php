<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    use HasFactory;
    protected $table = 'services';
    protected $fillable = [
        'user_id',
        'booking_id',
        'place_id',
        'service_type_id',
        'service_date',
        'service_time',
        'comment',
        'status'
    ];
    protected $casts = [
        'service_date' => 'date',
        'service_time' => 'datetime',
    ];
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }
    public function place(){
        return $this->belongsTo(Place::class, 'place_id', 'id');
    }
    public function serviceType()
    {
        return $this->belongsTo(ServiceType::class);
    }
}
