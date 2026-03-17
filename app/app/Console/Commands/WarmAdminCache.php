<?php

namespace App\Console\Commands;

use App\Models\Order;
use App\Models\Service;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Carbon;

class WarmAdminCache extends Command
{
    protected $signature = 'cache:warm-admin';
    protected $description = 'Pre-warm admin dashboard cache for instant load times';

    public function handle()
    {
        $this->info('🔥 Warming admin dashboard cache...');

        try {
            // Warm stats cache
            $this->line('  → Caching stats...');
            Cache::remember('admin_stats', 300, function () {
                $today = Carbon::today();
                return [
                    'total_bookings' => Order::select(DB::raw('COUNT(*) as cnt'))->value('cnt') ?? 0,
                    'pending_count'  => Order::where('status', 'pending')
                                            ->select(DB::raw('COUNT(*) as cnt'))
                                            ->value('cnt') ?? 0,
                    'revenue_today'  => (float) Order::whereDate('created_at', $today)
                                                     ->where('status', '!=', 'cancelled')
                                                     ->sum('total_price') ?? 0,
                    'customer_count' => \App\Models\User::where('role', 'customer')
                                           ->select(DB::raw('COUNT(*) as cnt'))
                                           ->value('cnt') ?? 0,
                ];
            });

            // Warm recent orders cache
            $this->line('  → Caching recent orders...');
            Cache::remember('admin_recent_orders', 180, function () {
                return Order::with(['user', 'service'])
                    ->latest()
                    ->take(5)
                    ->get()
                    ->map(function ($order) {
                        return [
                            'order_id' => $order->id,
                            'id'       => '#LH-' . str_pad($order->id, 3, '0', STR_PAD_LEFT),
                            'customer_name' => $order->user?->name ?? 'Unknown',
                            'service_type'  => $order->service?->name ?? 'Unknown Service',
                            'weight_kg' => (int)$order->weight_kg,
                            'pickup_address' => $order->pickup_address,
                            'pickup_date' => $order->pickup_date,
                            'delivery_date' => $order->delivery_date,
                            'total_price' => $order->total_price,
                            'status'   => ucfirst($order->status),
                        ];
                    });
            });

            // Warm analytics cache
            $this->line('  → Caching analytics...');
            Cache::remember('admin_analytics', 600, function () {
                $now = Carbon::now();
                $weekStart = $now->copy()->startOfWeek(Carbon::MONDAY);
                
                $weeklyRevenue = [];
                for ($i = 0; $i < 7; $i++) {
                    $day = $weekStart->copy()->addDays($i);
                    $weeklyRevenue[] = (float) Order::whereDate('created_at', $day)
                        ->where('status', '!=', 'cancelled')
                        ->sum('total_price');
                }

                $serviceBreakdown = Order::select(
                        DB::raw('services.name as service_name'),
                        DB::raw('COUNT(*) as order_count')
                    )
                    ->join('services', 'orders.service_id', '=', 'services.id')
                    ->where('orders.status', '!=', 'cancelled')
                    ->groupBy('services.id', 'services.name')
                    ->orderByDesc('order_count')
                    ->get();

                $totalOrders = $serviceBreakdown->sum('order_count');
                $top3 = [];
                $othersCount = 0;

                foreach ($serviceBreakdown as $index => $item) {
                    if ($index < 3) {
                        $top3[] = [
                            'name' => $item->service_name,
                            'pct'  => round(($item->order_count / max($totalOrders, 1)) * 100),
                        ];
                    } else {
                        $othersCount += $item->order_count;
                    }
                }

                if ($othersCount > 0) {
                    $top3[] = [
                        'name' => 'Others',
                        'pct'  => round(($othersCount / max($totalOrders, 1)) * 100),
                    ];
                }

                $monthlyRevenue = Order::whereYear('created_at', $now->year)
                    ->whereMonth('created_at', $now->month)
                    ->where('status', '!=', 'cancelled')
                    ->sum('total_price');

                return [
                    'weekly_revenue'    => $weeklyRevenue,
                    'service_breakdown' => $top3,
                    'monthly_revenue'   => $monthlyRevenue,
                    'month_label'       => $now->format('F Y'),
                ];
            });

            $this->info('✅ Admin cache warmed successfully!');
            return 0;
        } catch (\Exception $e) {
            $this->error('❌ Failed to warm cache: ' . $e->getMessage());
            return 1;
        }
    }
}
