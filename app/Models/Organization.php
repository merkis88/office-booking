<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Organization extends Model
{
    use HasFactory;

    protected $table = 'organizations';
    protected $fillable = [
        'name'
    ];

    public function place()
    {
        return $this->hasMany(Place::class, 'organization_id');
    }

    public function booking()
    {
        return $this->hasMany(Booking::class, 'organization_id');
    }
}
