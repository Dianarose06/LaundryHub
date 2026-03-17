<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    private function ensureAdmin(Request $request): void
    {
        if ($request->user()?->role !== 'admin') {
            abort(403, 'Forbidden: Admin access required.');
        }
    }

    private function getServiceEmoji(string $serviceName): string
    {
        $normalized = strtolower(trim($serviceName));

        if (str_contains($normalized, 'wash-dry-fold') || str_contains($normalized, 'wash–dry–fold')) {
            return '🧺';
        } elseif (str_contains($normalized, 'dry cleaning')) {
            return '✨';
        } elseif (str_contains($normalized, 'beddings')) {
            return '🛏️';
        } elseif (str_contains($normalized, 'express wash')) {
            return '⚡';
        } elseif (str_contains($normalized, 'soft wash')) {
            return '🌸';
        }

        return '🧺';
    }

    public function stats(Request $request)
    {
        $this->ensureAdmin($request);

        $stats = Cache::remember('admin_stats', 300, function () {
            $today = Carbon::today();

            return [
                'total_bookings' => Order::count(),
                'pending_count'  => Order::where('status', 'pending')->count(),
                'revenue_today'  => (float) Order::whereDate('created_at', $today)
                    ->where('status', '!=', 'cancelled')
                    ->sum('total_price'),
                'customer_count' => User::where('role', 'customer')->count(),
            ];
        });

        return response()->json($stats)
            ->header('Cache-Control', 'public, max-age=300');
    }

    public function recentOrders(Request $request)
    {
        $this->ensureAdmin($request);

        $orders = Cache::remember('admin_recent_orders', 180, function () {
            return Order::with(['user', 'service'])
                ->latest()
                ->take(5)
                ->get()
                ->map(fn ($order) => [
                    'order_id' => $order->id,
                    'id'       => '#LH-' . str_pad($order->id, 3, '0', STR_PAD_LEFT),
                    'customer_name' => $order->user?->name ?? 'Unknown',
                    'service_type'  => $order->service?->name ?? 'Unknown Service',
                    'service_emoji' => $this->getServiceEmoji($order->service?->name ?? ''),
                    'weight_kg' => (int)$order->weight_kg,
                    'pickup_address' => $order->pickup_address,
                    'pickup_date' => $order->pickup_date,
                    'delivery_date' => $order->delivery_date,
                    'delivery_type' => $order->delivery_type ?? 'pickup',
                    'total_price' => $order->total_price,
                    'status'   => ucfirst($order->status),
                ]);
        });

        return response()->json(['data' => $orders])
            ->header('Cache-Control', 'public, max-age=180');
    }

    public function orders(Request $request)
    {
        $this->ensureAdmin($request);

        $perPage = min((int)$request->query('per_page', 20), 100);

        $query = Order::with(['user', 'service'])->latest();

        if ($request->filled('status') && $request->status !== 'all') {
            $query->where('status', $request->status);
        }

        $paginated = $query->paginate($perPage);

        $orders = $paginated->map(fn ($order) => [
            'order_id' => $order->id,
            'id'       => '#LH-' . str_pad($order->id, 3, '0', STR_PAD_LEFT),
            'customer_name' => $order->user?->name ?? 'Unknown',
            'service_type' => $order->service?->name ?? 'Unknown Service',
            'service_emoji' => $this->getServiceEmoji($order->service?->name ?? ''),
            'weight_kg' => (int)$order->weight_kg,
            'pickup_address' => $order->pickup_address,
            'pickup_date' => $order->pickup_date,
            'delivery_date' => $order->delivery_date,
            'delivery_type' => $order->delivery_type ?? 'pickup',
            'total_price' => $order->total_price,
            'status'   => ucfirst($order->status),
            'created_at' => $order->created_at,
            'updated_at' => $order->updated_at,
        ]);

        return response()->json([
            'data' => $orders,
            'pagination' => [
                'total' => $paginated->total(),
                'count' => $paginated->count(),
                'per_page' => $paginated->perPage(),
                'current_page' => $paginated->currentPage(),
                'last_page' => $paginated->lastPage(),
            ],
        ]);
    }

    public function updateOrderStatus(Request $request, Order $order)
    {
        $this->ensureAdmin($request);

        $validated = $request->validate([
            'status' => ['required', Rule::in(['pending', 'ongoing', 'ready', 'completed', 'cancelled'])],
        ]);

        $order->update(['status' => $validated['status']]);

        return response()->json(['data' => $order]);
    }

    public function topCustomers(Request $request)
    {
        $this->ensureAdmin($request);

        $customers = User::where('role', 'customer')
            ->withCount('orders')
            ->withSum(['orders' => fn ($q) => $q->where('status', '!=', 'cancelled')], 'total_price')
            ->having('orders_count', '>', 0)
            ->orderByDesc('orders_sum_total_price')
            ->limit(5)
            ->get()
            ->map(fn ($u) => [
                'name'   => $u->name,
                'orders' => $u->orders_count,
                'spend'  => '₱' . number_format($u->orders_sum_total_price ?? 0, 0),
            ]);

        return response()->json(['data' => $customers]);
    }

    public function analytics(Request $request)
    {
        $this->ensureAdmin($request);

        $data = Cache::remember('admin_analytics', 600, function () {

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
                        'name'  => $item->service_name ?? 'Unknown',
                        'count' => $item->order_count,
                        'pct'   => $totalOrders > 0 ? (int) round($item->order_count / $totalOrders * 100) : 0,
                    ];

                } else {

                    $othersCount += $item->order_count;

                }

            }

            if ($othersCount > 0) {

                $top3[] = [
                    'name'  => 'Others',
                    'count' => $othersCount,
                    'pct'   => $totalOrders > 0 ? (int) round($othersCount / $totalOrders * 100) : 0,
                ];

            }

            $monthlyRevenue = (float) Order::whereMonth('created_at', $now->month)
                ->whereYear('created_at', $now->year)
                ->where('status', '!=', 'cancelled')
                ->sum('total_price');

            return [
                'weekly_revenue'    => $weeklyRevenue,
                'service_breakdown' => $top3,
                'monthly_revenue'   => $monthlyRevenue,
                'month_label'       => $now->format('F Y'),
            ];
        });

        return response()->json($data)
            ->header('Cache-Control', 'public, max-age=600');
    }
}