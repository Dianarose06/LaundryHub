<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Validation\Rule;

class AdminController extends Controller
{
    private function ensureAdmin(Request $request): void
    {
        if ($request->user()?->role !== 'admin') {
            abort(403, 'Forbidden: Admin access required.');
        }
    }

    public function stats(Request $request)
    {
        $this->ensureAdmin($request);

        $today = Carbon::today();

        return response()->json([
            'total_bookings' => Order::count(),
            'pending_count'  => Order::where('status', 'pending')->count(),
            'revenue_today'  => Order::whereDate('created_at', $today)
                                     ->where('status', '!=', 'cancelled')
                                     ->sum('total_price'),
            'customer_count' => User::where('role', 'customer')->count(),
        ]);
    }

    public function recentOrders(Request $request)
    {
        $this->ensureAdmin($request);

        $orders = Order::with(['user', 'service'])
            ->latest()
            ->take(5)
            ->get()
            ->map(fn ($order) => [
                'order_id' => $order->id,
                'id'       => '#LH-' . str_pad($order->id, 3, '0', STR_PAD_LEFT),
                'customer' => $order->user?->name ?? 'Unknown',
                'service'  => $order->service?->name ?? 'Unknown Service',
                'status'   => ucfirst($order->status),
                'amount'   => '₱' . number_format($order->total_price, 0),
            ]);

        return response()->json(['data' => $orders]);
    }

    public function orders(Request $request)
    {
        $this->ensureAdmin($request);

        $query = Order::with(['user', 'service'])->latest();

        if ($request->filled('status') && $request->status !== 'all') {
            $query->where('status', $request->status);
        }

        $orders = $query->get()->map(fn ($order) => [
            'order_id' => $order->id,
            'id'       => '#LH-' . str_pad($order->id, 3, '0', STR_PAD_LEFT),
            'customer' => $order->user?->name ?? 'Unknown',
            'service'  => $order->service?->name ?? 'Unknown Service',
            'date'     => optional($order->created_at)->format('M j, Y · g:i A') ?? '—',
            'cost'     => '₱' . number_format($order->total_price, 0),
            'status'   => ucfirst($order->status),
        ]);

        return response()->json(['data' => $orders]);
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

        $now = Carbon::now();

        // ── Weekly revenue (Mon–Sun of current week) ──────────────────────────
        $weekStart = $now->copy()->startOfWeek(Carbon::MONDAY);
        $weeklyRevenue = [];
        for ($i = 0; $i < 7; $i++) {
            $day = $weekStart->copy()->addDays($i);
            $weeklyRevenue[] = (float) Order::whereDate('created_at', $day)
                ->where('status', '!=', 'cancelled')
                ->sum('total_price');
        }

        // ── Service breakdown (top 3 by order count + "Others") ──────────────
        $allServiceGroups = Order::with('service')
            ->where('status', '!=', 'cancelled')
            ->get()
            ->groupBy(fn ($o) => $o->service?->name ?? 'Unknown');

        $totalOrders = $allServiceGroups->sum(fn ($g) => $g->count());

        $sorted = $allServiceGroups->map(fn ($g, $name) => [
            'name'  => $name,
            'count' => $g->count(),
            'pct'   => $totalOrders > 0 ? (int) round($g->count() / $totalOrders * 100) : 0,
        ])->sortByDesc('count')->values();

        $top3         = $sorted->take(3)->toArray();
        $othersCount  = $sorted->skip(3)->sum('count');
        $othersPct    = $totalOrders > 0 ? (int) round($othersCount / $totalOrders * 100) : 0;

        if ($othersCount > 0) {
            $top3[] = ['name' => 'Others', 'count' => $othersCount, 'pct' => $othersPct];
        }

        // ── Monthly revenue ────────────────────────────────────────────────────
        $monthlyRevenue = (float) Order::whereMonth('created_at', $now->month)
            ->whereYear('created_at', $now->year)
            ->where('status', '!=', 'cancelled')
            ->sum('total_price');

        return response()->json([
            'weekly_revenue'    => $weeklyRevenue,
            'service_breakdown' => array_values($top3),
            'monthly_revenue'   => $monthlyRevenue,
            'month_label'       => $now->format('F Y'),
        ]);
    }
}
