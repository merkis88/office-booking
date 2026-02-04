<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Parking_place extends Model
{
    use HasFactory;
    protected $table = 'parking_places';
    protected $fillable = [
        'place_row',
        'status',
    ];

    public function parking_place()
    {
        return $this->hasMany(Booking::class, 'parking_place_id');
    }
}
