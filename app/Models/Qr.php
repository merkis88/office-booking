<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Qr extends Model
{
    protected $fillable = [
        'booking_id',
        'time_window',
        'user_id',
        'recipient_email',
        'hash',
        'used_at',
    ];

    protected $casts = [
        'used_at' => 'datetime',
    ];

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
