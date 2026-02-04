<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Qr extends Model
{
    use HasFactory;
    protected $table = 'qrs';
    protected $fillable = [
        'booking_id',
        'hash',
        'used_at'
    ];
    public function booking(){
        return $this->belongsTo(Booking::class, 'booking_id', 'id');
    }
}
