<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    use HasFactory;
    protected $table = 'services';
    protected $fillable = [
        'place_id',
        'date_service',
        'type_service',
        'comment'
    ];
    public function place(){
        return $this->belongsTo(Place::class, 'place_id', 'id');
    }
}
