<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Place extends Model
{
    use HasFactory;
    protected $table = 'places';
    protected $fillable = [
        'organization_id',
        'name',
        'type',
        'capacity',
        'is_active'
    ];

    public function organization()
    {
        return $this->belongsTo(Organization::class, 'organization_id', 'id');
    }

    public function service()
    {
        return $this->hasMany(Service::class, 'place_id');
    }

    public function booking()
    {
        return $this->hasMany(Booking::class, 'place_id');
    }
}
