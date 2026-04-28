<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Barangay extends Model
{
    use HasFactory;

    protected $fillable = [
        'city',
        'name',
        'zone',
        'pickup_fee',
        'delivery_fee',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'zone' => 'integer',
            'pickup_fee' => 'decimal:2',
            'delivery_fee' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function orders()
    {
        return $this->hasMany(Order::class, 'pickup_barangay_id');
    }
}
