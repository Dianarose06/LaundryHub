<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'service_id',
        'weight_kg',
        'total_price',
        'status',
        'pickup_address',
        'pickup_date',
        'pickup_time',
        'delivery_date',
        'delivery_time',
        'delivery_type',
        'notes',
        'admin_notes',
    ];

    protected function casts(): array
    {
        return [
            'weight_kg'   => 'decimal:2',
            'total_price' => 'decimal:2',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function service()
    {
        return $this->belongsTo(Service::class);
    }
}
