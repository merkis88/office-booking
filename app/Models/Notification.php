<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    use HasFactory;
    protected $table = 'notifications';
    protected $fillable = [
        'title',
        'message',
        'created_by',
        'user_id',
        'is_for_all',
        'read_at',
    ];
    protected $casts = [
        'read_at' => 'datetime',
        'is_for_all' => 'boolean',
    ];

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function scopeUnread($query)
    {
        return $query->whereNull('read_at');
    }

    public function scopeForUser($query, $userId)
    {
        return $query->where(function ($q) use ($userId) {
            $q->where('user_id', $userId)->orWhere('is_for_all', true);
        });
    }

    public function markAsRead()
    {
        $this->update(['read_at' => now()]);
    }

    public function isRead():bool
    {
        return $this->read_at !== null;
    }
}
