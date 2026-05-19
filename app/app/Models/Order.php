<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Cache;
use App\Services\BookingSummaryService;
use Illuminate\Support\Carbon;
use App\Models\Service;
use App\Models\AddOnService;
use App\Models\Barangay;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'service_id',
        'weight_kg',
        'total_price',
        'add_on_total',
        'pickup_fee',
        'delivery_fee',
        'fee_zone',
        'status',
        'pickup_address',
        'pickup_barangay_id',
        'pickup_city',
        'pickup_barangay',
        'pickup_date',
        'pickup_time',
        'delivery_date',
        'delivery_time',
        'delivery_type',
        'type',
        'laundry_photo',
        'notes',
        'admin_notes',
    ];

    protected function casts(): array
    {
        return [
            'weight_kg'   => 'decimal:2',
            'total_price' => 'decimal:2',
            'add_on_total' => 'decimal:2',
            'pickup_fee' => 'decimal:2',
            'delivery_fee' => 'decimal:2',
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
        return $this->belongsTo(\App\Models\User::class);
    }

    public function service()
    {
        return $this->belongsTo(Service::class);
    }

    public function pickupBarangay()
    {
        return $this->belongsTo(Barangay::class, 'pickup_barangay_id');
    }

    public function addOnServices()
    {
        return $this->belongsToMany(AddOnService::class, 'order_add_on_services')
            ->withPivot('fee')
            ->withTimestamps();
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeCompletedToday($query, $date = null)
    {
        $date = $date ?: Carbon::today();
        return $query->where('status', 'completed')
            ->whereDate('completed_at', $date);
    }

    public function scopePendingPickup($query)
    {
        return $query->where('status', 'pending')
            ->where('delivery_type', 'pickup');
    }

    public function getDisplayIdAttribute()
    {
        return '#LH-' . str_pad((string) $this->id, 3, '0', STR_PAD_LEFT);
    }
}
