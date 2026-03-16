<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Cache;
use App\Services\BookingSummaryService;
use Illuminate\Support\Carbon;

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

    protected static function boot()
    {
        parent::boot();

        // Clear admin dashboard cache and update booking summary whenever an order is created, updated, or deleted
        static::created(function ($order) {
            static::invalidateAdminCache();
            BookingSummaryService::updateSummary(Carbon::today());
        });
        
        static::updated(function ($order) {
            static::invalidateAdminCache();
            BookingSummaryService::updateSummary(Carbon::today());
        });
        
        static::deleted(function ($order) {
            static::invalidateAdminCache();
            BookingSummaryService::updateSummary(Carbon::today());
        });
    }

    protected static function invalidateAdminCache(): void
    {
        Cache::forget('admin_stats');
        Cache::forget('admin_analytics');
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

