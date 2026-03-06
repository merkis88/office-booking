<?php

namespace App\Models;

use Carbon\Carbon;
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
        'status',
        'completed_at'
    ];
    protected $casts = [
        'service_date' => 'date',
        'service_time' => 'datetime',
        'completed_at' => 'datetime'
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

    public function scopeActive($query)
    {
        return $query->whereNull('completed_at');
    }

    public function scopeCompleted($query)
    {
        return $query->whereNotNull('completed_at');
    }
    public function isCompleted(): bool
    {
        return $this->completed_at !== null;
    }
    public function markAsCompleted(): void
    {
        $this->status = 'completed';
        $this->completed_at = Carbon::now();
        $this->save();
    }
}
