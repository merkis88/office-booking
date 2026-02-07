<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PlaceManager extends Model
{
    use HasFactory;

    protected $table = 'place_managers';

    protected $fillable = [
        'place_id',
        'user_id',
        'created_from_booking_id',
    ];
}
