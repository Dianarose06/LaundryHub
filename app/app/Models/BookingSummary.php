<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BookingSummary extends Model
{
    protected $fillable = [
        'summary_date',
        'total_bookings',
        'requested_bookings',
        'accepted_bookings',
        'declined_bookings',
        'completed_bookings',
        'cancelled_bookings',
        'total_revenue',
        'total_weight_kg',
    ];

    protected function casts(): array
    {
        return [
            'summary_date' => 'date',
            'total_revenue' => 'decimal:2',
            'total_weight_kg' => 'decimal:2',
        ];
    }
}
