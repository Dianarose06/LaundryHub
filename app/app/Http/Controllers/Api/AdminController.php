<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Notifications\OrderDeliveryScheduled;
use App\Notifications\OrderPaymentReceipt;
use App\Notifications\OrderReadyForPickup;
use App\Notifications\OrderRefundInitiated;
use App\Notifications\OrderStatusUpdated;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Illuminate\Validation\Rule;

class AdminController extends Controller
{
    private const LOYALTY_POINTS_PER_100_PHP = 1;

    private function isEmailNotificationEnabled(User $user): bool
    {
        return !empty($user->email) && $user->notifications_enabled !== false;
    }

    private function sendPaymentReceiptEmail(Order $order): void
    {
        $order->loadMissing(['user', 'service']);

        $user = $order->user;

        if (!$user || !$this->isEmailNotificationEnabled($user)) {
            return;
        }

        try {
            $user->notify(new OrderPaymentReceipt($order));
        } catch (\Throwable $exception) {
            Log::warning('Unable to send payment receipt email.', [
                'order_id' => $order->id,
                'user_id' => $user->id,
                'error' => $exception->getMessage(),
            ]);
        }
    }

    private function sendReadyForPickupEmail(Order $order): void
    {
        $order->loadMissing(['user', 'service']);

        $user = $order->user;

        if (!$user || !$this->isEmailNotificationEnabled($user)) {
            return;
        }

        try {
            $user->notify(new OrderReadyForPickup($order));
        } catch (\Throwable $exception) {
            Log::warning('Unable to send ready-for-pickup email.', [
                'order_id' => $order->id,
                'user_id' => $user->id,
                'error' => $exception->getMessage(),
            ]);
        }
    }

    private function sendDeliveryScheduledEmail(Order $order): void
    {
        $order->loadMissing(['user', 'service']);

        $user = $order->user;

        if (!$user || !$this->isEmailNotificationEnabled($user)) {
            return;
        }

        try {
            $user->notify(new OrderDeliveryScheduled($order));
        } catch (\Throwable $exception) {
            Log::warning('Unable to send delivery-scheduled email.', [
                'order_id' => $order->id,
                'user_id' => $user->id,
                'error' => $exception->getMessage(),
            ]);
        }
    }

    private function sendRefundInitiatedEmail(Order $order, string $reason): void
    {
        $order->loadMissing(['user', 'service']);

        $user = $order->user;

        if (!$user || !$this->isEmailNotificationEnabled($user)) {
            return;
        }

        try {
            $user->notify(new OrderRefundInitiated($order, $reason));
        } catch (\Throwable $exception) {
            Log::warning('Unable to send refund-initiated email.', [
                'order_id' => $order->id,
                'user_id' => $user->id,
                'error' => $exception->getMessage(),
            ]);
        }
    }

    private function sendOrderStatusEmail(Order $order, string $previousStatus, string $nextStatus): void
    {
        $order->loadMissing(['user', 'service']);

        $user = $order->user;

        if (!$user || !$this->isEmailNotificationEnabled($user)) {
            return;
        }

        try {
            $user->notify(new OrderStatusUpdated($order, $previousStatus, $nextStatus));
        } catch (\Throwable $exception) {
            Log::warning('Unable to send order status email.', [
                'order_id' => $order->id,
                'user_id' => $user->id,
                'from_status' => $previousStatus,
                'to_status' => $nextStatus,
                'error' => $exception->getMessage(),
            ]);
        }
    }

    private function formatDisplayName(string $firstName, string $lastName, ?string $middleInitial = null): string
    {
        $normalizedFirstName = trim($firstName);
        $normalizedLastName = trim($lastName);
        $normalizedMiddleInitial = $middleInitial !== null ? strtoupper(trim($middleInitial)) : null;

        return !empty($normalizedMiddleInitial)
            ? "{$normalizedLastName}, {$normalizedFirstName} {$normalizedMiddleInitial}."
            : "{$normalizedLastName}, {$normalizedFirstName}";
    }

    private function ensureAdmin(Request $request): void
    {
        if ($request->user()?->role !== 'admin') {
            abort(403, 'Forbidden: Admin access required.');
        }
    }

    private function hasOrderColumn(string $column): bool
    {
        return Schema::hasColumn('orders', $column);
    }

    private function orderCustomerJoinExpression(): string
    {
        $hasCustomerId = $this->hasOrderColumn('customer_id');
        $hasUserId = $this->hasOrderColumn('user_id');

        if ($hasCustomerId && $hasUserId) {
            return 'COALESCE(NULLIF(orders.customer_id, 0), orders.user_id)';
        }

        if ($hasCustomerId) {
            return 'orders.customer_id';
        }

        return 'orders.user_id';
    }

    private function orderCustomerGroupExpression(): string
    {
        return str_replace('orders.', '', $this->orderCustomerJoinExpression());
    }

    private function orderAmountExpression(): string
    {
        $hasTotalPayment = $this->hasOrderColumn('total_payment');
        $hasTotalPrice = $this->hasOrderColumn('total_price');

        if ($hasTotalPayment && $hasTotalPrice) {
            return 'COALESCE(NULLIF(orders.total_payment, 0), orders.total_price, 0)';
        }

        if ($hasTotalPayment) {
            return 'COALESCE(orders.total_payment, 0)';
        }

        return 'COALESCE(orders.total_price, 0)';
    }

    private function customerRoleCount(): int
    {
        return (int) User::query()
            ->whereRaw('LOWER(role) = ?', ['customer'])
            ->count();
    }

    private function applyNotCancelledFilter($query, string $qualifiedStatusColumn = 'status')
    {
        return $query->where(function ($statusQuery) use ($qualifiedStatusColumn) {
            $statusQuery->whereNull($qualifiedStatusColumn)
                ->orWhereRaw("LOWER({$qualifiedStatusColumn}) <> ?", ['cancelled']);
        });
    }

    private function calculateLoyaltyPointsForOrder(Order $order): int
    {
        $totalPrice = (float) $order->total_price;
        $points = (int) floor($totalPrice / 100) * self::LOYALTY_POINTS_PER_100_PHP;

        return max(1, $points);
    }

    private function getServiceEmoji(string $serviceName): string
    {
        $normalized = strtolower(trim($serviceName));

        if (str_contains($normalized, 'wash-dry-fold') || str_contains($normalized, 'wash–dry–fold')) {
            return "\u{1F9FA}";
        } elseif (str_contains($normalized, 'dry cleaning')) {
            return "\u{2728}";
        } elseif (str_contains($normalized, 'beddings')) {
            return "\u{1F6CF}\u{FE0F}";
        } elseif (str_contains($normalized, 'express wash')) {
            return "\u{26A1}";
        } elseif (str_contains($normalized, 'soft wash')) {
            return "\u{1F338}";
        }

        return "\u{1F9FA}";
    }

    private function percentageChange(float $current, float $previous): ?int
    {
        if ($previous == 0.0) {
            return $current > 0.0 ? 100 : null;
        }

        return (int) round((($current - $previous) / $previous) * 100);
    }

    public function stats(Request $request)
    {
        $this->ensureAdmin($request);

        $today = Carbon::today();
        $amountExpression = $this->orderAmountExpression();

        $revenueQuery = DB::table('orders')
            ->where('status', 'completed');
        if (Schema::hasColumn('orders', 'completed_at')) {
            $revenueQuery->whereDate('completed_at', $today);
        } else {
            $revenueQuery->whereDate('created_at', $today);
        }

        $stats = [
            'total_bookings' => Order::count(),
            'pending_count'  => Order::where('status', 'pending')->count(),
            'revenue_today'  => (float) $revenueQuery->sum(DB::raw($amountExpression)),
            'customer_count' => $this->customerRoleCount(),
        ];

        return response()->json($stats)
            ->header('Cache-Control', 'no-cache, no-store, must-revalidate');
    }

    public function recentOrders(Request $request)
    {
        $this->ensureAdmin($request);
        $amountExpression = $this->orderAmountExpression();
        $customerJoinExpression = $this->orderCustomerJoinExpression();

        // Don't cache - return fresh data to avoid stale prices
        $orders = Order::query()
            ->leftJoin('users', function ($join) use ($customerJoinExpression) {
                $join->whereRaw("{$customerJoinExpression} = users.id");
            })
            ->leftJoin('services', 'orders.service_id', '=', 'services.id')
            ->select(
                'orders.*',
                DB::raw('users.name as customer_name_raw'),
                DB::raw('services.name as service_name_raw'),
                DB::raw("{$amountExpression} as total_amount_raw")
            )
            ->latest('orders.id')
            ->take(5)
            ->get()
            ->map(fn ($order) => [
                'order_id' => $order->id,
                'id'       => '#LH-' . str_pad($order->id, 3, '0', STR_PAD_LEFT),
                'customer_name' => $order->customer_name_raw ?? 'Unknown',
                'service_type'  => $order->service_name_raw ?? 'Unknown Service',
                'service_emoji' => $this->getServiceEmoji($order->service_name_raw ?? ''),
                'weight_kg' => (int)$order->weight_kg,
                'pickup_address' => $order->pickup_address,
                'pickup_date' => $order->pickup_date,
                'delivery_date' => $order->delivery_date,
                'delivery_type' => $order->delivery_type ?? 'pickup',
                'type' => $order->type ?? (($order->delivery_type ?? 'pickup') === 'delivery' ? 'dropoff' : 'pickup'),
                'delivery_fee' => (float) ($order->delivery_fee ?? 0),
                'laundry_photo' => $order->laundry_photo,
                'laundry_photo_url' => $order->laundry_photo ? asset($order->laundry_photo) : null,
                'total_price' => (float) ($order->total_amount_raw ?? 0),
                'status'   => ucfirst($order->status),
            ]);

        return response()->json(['data' => $orders])
            ->header('Cache-Control', 'no-cache, no-store, must-revalidate');
    }

    public function orders(Request $request)
    {
        $this->ensureAdmin($request);
        $customerJoinExpression = $this->orderCustomerJoinExpression();
        $amountExpression = $this->orderAmountExpression();

        $perPage = min((int)$request->query('per_page', 20), 100);
        $rawSearch = trim((string) $request->query('search', ''));
        $normalizedSearch = preg_replace('/\s+/', ' ', $rawSearch);
        $normalizedSearch = trim((string) $normalizedSearch);

        $query = Order::query()
            ->leftJoin('users', function ($join) use ($customerJoinExpression) {
                $join->whereRaw("{$customerJoinExpression} = users.id");
            })
            ->leftJoin('services', 'orders.service_id', '=', 'services.id')
            ->select(
                'orders.*',
                DB::raw('users.name as customer_name_raw'),
                DB::raw('services.name as service_name_raw'),
                DB::raw("{$amountExpression} as total_amount_raw")
            )
            ->latest('orders.id');

        if ($request->filled('status') && $request->status !== 'all') {
            $query->where('status', $request->status);
        }
        if ($normalizedSearch !== '') {
            $lowered = mb_strtolower($normalizedSearch);
            $digits = preg_replace('/\D+/', '', $normalizedSearch);
            $orderIdCandidate = null;
            if (preg_match('/(?:#?\s*lh[-\s]*)?(\d+)/i', $normalizedSearch, $matches)) {
                $orderIdCandidate = (int) ltrim($matches[1], '0');
            }

            $query->where(function ($searchQuery) use ($lowered, $digits, $orderIdCandidate) {
                if ($orderIdCandidate !== null && $orderIdCandidate > 0) {
                    $searchQuery->orWhere('orders.id', $orderIdCandidate);
                } elseif ($digits !== '' && strlen($digits) <= 6) {
                    $searchQuery->orWhere('orders.id', (int) $digits);
                }

                $searchQuery->orWhereRaw('LOWER(COALESCE(users.name, \'\')) LIKE ?', ['%' . $lowered . '%']);
            });
        }

        $paginated = $query->paginate($perPage);

        $orders = $paginated->map(fn ($order) => [
            'order_id' => $order->id,
            'id'       => '#LH-' . str_pad($order->id, 3, '0', STR_PAD_LEFT),
            'customer_name' => $order->customer_name_raw ?? 'Unknown',
            'service_type' => $order->service_name_raw ?? 'Unknown Service',
            'service_emoji' => $this->getServiceEmoji($order->service_name_raw ?? ''),
            'weight_kg' => (float)$order->weight_kg,
            'pickup_address' => $order->pickup_address,
            'pickup_date' => $order->pickup_date,
            'delivery_date' => $order->delivery_date,
            'delivery_type' => $order->delivery_type ?? 'pickup',
            'type' => $order->type ?? (($order->delivery_type ?? 'pickup') === 'delivery' ? 'dropoff' : 'pickup'),
            'delivery_fee' => (float) ($order->delivery_fee ?? 0),
            'laundry_photo' => $order->laundry_photo,
            'laundry_photo_url' => $order->laundry_photo ? asset($order->laundry_photo) : null,
            'total_price' => (float) ($order->total_amount_raw ?? 0),
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

    public function bookingSummaries(Request $request)
    {
        $this->ensureAdmin($request);

        $statusCounts = Order::query()
            ->select('status', DB::raw('COUNT(*) as total'))
            ->groupBy('status')
            ->pluck('total', 'status')
            ->map(fn ($count) => (int) $count);

        $byStatus = [
            'pending' => (int) ($statusCounts['pending'] ?? 0),
            'ongoing' => (int) ($statusCounts['ongoing'] ?? 0),
            'ready' => (int) ($statusCounts['ready'] ?? 0),
            'completed' => (int) ($statusCounts['completed'] ?? 0),
            'cancelled' => (int) ($statusCounts['cancelled'] ?? 0),
        ];

        return response()->json([
            'data' => [
                'total' => array_sum($byStatus),
                'by_status' => $byStatus,
                'requested_bookings' => $byStatus['pending'],
                'accepted_bookings' => $byStatus['ongoing'] + $byStatus['ready'],
                'completed_bookings' => $byStatus['completed'],
                'cancelled_bookings' => $byStatus['cancelled'],
            ],
        ])->header('Cache-Control', 'no-cache, no-store, must-revalidate');
    }

    public function updateOrderStatus(Request $request, Order $order)
    {
        $this->ensureAdmin($request);

        $validated = $request->validate([
            'status' => ['required', Rule::in(['pending', 'ongoing', 'ready', 'completed', 'cancelled'])],
        ]);

        $previousStatus = $order->status;
        $nextStatus = $validated['status'];
        $awardedPoints = 0;

        if ($previousStatus !== $nextStatus) {
            $updatePayload = ['status' => $nextStatus];
            if ($nextStatus === 'completed') {
                $updatePayload['completed_at'] = now();
            } elseif ($previousStatus === 'completed') {
                $updatePayload['completed_at'] = null;
            }
            $order->update($updatePayload);

            $this->sendOrderStatusEmail($order, $previousStatus, $nextStatus);

            if ($nextStatus === 'ready') {
                $orderType = $order->type ?? (($order->delivery_type ?? 'pickup') === 'delivery' ? 'dropoff' : 'pickup');
                if ($orderType !== 'dropoff' && ($order->delivery_type ?? 'pickup') === 'delivery') {
                    $this->sendDeliveryScheduledEmail($order);
                } else {
                    $this->sendReadyForPickupEmail($order);
                }
            }

            if ($nextStatus === 'cancelled') {
                $this->sendRefundInitiatedEmail($order, 'Order was cancelled by admin.');
            }

            // Award points only on first transition into completed state.
            if ($previousStatus !== 'completed' && $nextStatus === 'completed') {
                $awardedPoints = $this->calculateLoyaltyPointsForOrder($order);
                $order->user()->increment('loyalty_points', $awardedPoints);

                // Send payment receipt email when order is completed and payment received
                $this->sendPaymentReceiptEmail($order);
            }
        }

        $order->refresh();
        $order->load('user');

        return response()->json([
            'data' => $order,
            'loyalty_points_awarded' => $awardedPoints,
            'customer_loyalty_points' => (int) ($order->user?->loyalty_points ?? 0),
        ]);
    }

    public function topCustomers(Request $request)
    {
        $this->ensureAdmin($request);
        $customerJoinExpression = $this->orderCustomerJoinExpression();
        $amountExpression = $this->orderAmountExpression();

        $customers = DB::table('users')
            ->join('orders', function ($join) use ($customerJoinExpression) {
                $join->whereRaw("{$customerJoinExpression} = users.id");
            })
            ->whereRaw('LOWER(users.role) = ?', ['customer'])
            ->where(function ($statusQuery) {
                $statusQuery->whereNull('orders.status')
                    ->orWhereRaw('LOWER(orders.status) <> ?', ['cancelled']);
            })
            ->groupBy('users.id', 'users.name')
            ->selectRaw("users.id, users.name, COUNT(orders.id) as orders_count, COALESCE(SUM({$amountExpression}), 0) as total_spend")
            ->orderByDesc('total_spend')
            ->limit(5)
            ->get()
            ->map(fn ($u) => [
                'name'   => $u->name,
                'orders' => (int) $u->orders_count,
                'spend_raw' => (float) ($u->total_spend ?? 0),
                'total_spend' => (float) ($u->total_spend ?? 0),
                'spend'  => 'PHP ' . number_format((float) ($u->total_spend ?? 0), 0),
            ]);

        return response()->json(['data' => $customers]);
    }

    public function analytics(Request $request)
    {
        $this->ensureAdmin($request);
        $customerJoinExpression = $this->orderCustomerJoinExpression();
        $amountExpression = $this->orderAmountExpression();

        $now = Carbon::now();
        $weekOffset = (int) $request->query('week_offset', 0);
        $startDateInput = trim((string) $request->query('start_date', ''));
        $endDateInput = trim((string) $request->query('end_date', ''));

        $customRange = null;
        if ($startDateInput !== '' && $endDateInput !== '') {
            try {
                $customStart = Carbon::createFromFormat('Y-m-d', $startDateInput)->startOfDay();
                $customEnd = Carbon::createFromFormat('Y-m-d', $endDateInput)->endOfDay();
                if ($customStart->lte($customEnd)) {
                    $customRange = [$customStart, $customEnd];
                }
            } catch (\Throwable $exception) {
                $customRange = null;
            }
        }

        $weekStart = $now->copy()->startOfWeek(Carbon::MONDAY)->addWeeks($weekOffset);
        $monthStart = $now->copy()->startOfMonth()->startOfDay();
        $monthEnd = $now->copy()->endOfMonth()->endOfDay();

        $chartStart = $customRange ? $customRange[0]->copy() : $weekStart->copy()->startOfDay();
        $chartEnd = $customRange ? $customRange[1]->copy() : $weekStart->copy()->addDays(6)->endOfDay();
        $chartMode = $customRange ? 'custom' : 'week';

        $chartRows = DB::table('orders')
            ->selectRaw("DATE(created_at) as revenue_date, SUM({$amountExpression}) as revenue")
            ->whereBetween('created_at', [$chartStart, $chartEnd])
            ->where(function ($statusQuery) {
                $statusQuery->whereNull('status')
                    ->orWhereRaw('LOWER(status) <> ?', ['cancelled']);
            })
            ->groupBy(DB::raw('DATE(created_at)'))
            ->pluck('revenue', 'revenue_date');

        $weeklyRevenue = [];
        $chartCursor = $chartStart->copy();
        while ($chartCursor->lte($chartEnd)) {
            $dayKey = $chartCursor->toDateString();
            $weeklyRevenue[] = [
                'date' => $dayKey,
                'day' => $chartCursor->format('D'),
                'label' => $chartMode === 'week' ? $chartCursor->format('D') : $chartCursor->format('M j'),
                'revenue' => (float) ($chartRows[$dayKey] ?? 0),
            ];
            $chartCursor->addDay();
        }

        $serviceBreakdown = DB::table('orders')
            ->selectRaw('services.name as service_name, COUNT(*) as order_count')
            ->join('services', 'orders.service_id', '=', 'services.id')
            ->where(function ($statusQuery) {
                $statusQuery->whereNull('orders.status')
                    ->orWhereRaw('LOWER(orders.status) <> ?', ['cancelled']);
            })
            ->groupBy('services.id', 'services.name')
            ->orderByDesc('order_count')
            ->get();

        $totalOrders = $serviceBreakdown->sum('order_count');

        $top3 = [];
        $othersCount = 0;
        $topService = null;

        foreach ($serviceBreakdown as $index => $item) {
            if ($index === 0) {
                $topService = [
                    'name' => $item->service_name ?? 'Unknown',
                    'orders' => (int) $item->order_count,
                ];
            }

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

        $monthlyRevenue = (float) $this->applyNotCancelledFilter(
            DB::table('orders')->whereBetween('created_at', [$monthStart, $monthEnd]),
            'status',
        )->sum(DB::raw($amountExpression));

        $monthlyStatusCounts = DB::table('orders')
            ->select('status', DB::raw('COUNT(*) as total'))
            ->whereBetween('created_at', [$monthStart, $monthEnd])
            ->groupBy('status')
            ->pluck('total', 'status')
            ->map(fn ($count) => (int) $count);

        $totalOrdersThisMonth = (int) $monthlyStatusCounts->sum();
        $completedOrdersThisMonth = (int) ($monthlyStatusCounts['completed'] ?? 0);
        $cancelledOrdersThisMonth = (int) ($monthlyStatusCounts['cancelled'] ?? 0);
        $activeOrdersThisMonth = max(0, $totalOrdersThisMonth - $cancelledOrdersThisMonth);
        $completionRate = $activeOrdersThisMonth > 0
            ? (int) round(($completedOrdersThisMonth / $activeOrdersThisMonth) * 100)
            : 0;

        $newCustomersThisMonth = User::whereRaw('LOWER(role) = ?', ['customer'])
            ->whereBetween('created_at', [$monthStart, $monthEnd])
            ->count();

        $totalCustomers = $this->customerRoleCount();

        $topCustomers = DB::table('users')
            ->join('orders', function ($join) use ($customerJoinExpression) {
                $join->whereRaw("{$customerJoinExpression} = users.id");
            })
            ->whereRaw('LOWER(users.role) = ?', ['customer'])
            ->where(function ($statusQuery) {
                $statusQuery->whereNull('orders.status')
                    ->orWhereRaw('LOWER(orders.status) <> ?', ['cancelled']);
            })
            ->groupBy('users.id', 'users.name')
            ->selectRaw("users.id, users.name, COUNT(orders.id) as orders_count, COALESCE(SUM({$amountExpression}), 0) as total_spend")
            ->orderByDesc('total_spend')
            ->limit(3)
            ->get()
            ->map(fn ($user) => [
                'name' => $user->name,
                'orders' => (int) $user->orders_count,
                'spend' => (float) ($user->total_spend ?? 0),
                'spend_label' => 'PHP ' . number_format($user->total_spend ?? 0, 0),
            ])
            ->values();

        $data = [
            'weekly_revenue'    => $weeklyRevenue,
            'service_breakdown' => $top3,
            'monthly_revenue'   => $monthlyRevenue,
            'total_orders_this_month' => $totalOrdersThisMonth,
            'completed_orders_this_month' => $completedOrdersThisMonth,
            'cancelled_orders_this_month' => $cancelledOrdersThisMonth,
            'new_customers_this_month' => $newCustomersThisMonth,
            'total_customers' => $totalCustomers,
            'completion_rate' => $completionRate,
            'top_service' => $topService,
            'top_customers' => $topCustomers,
            'month_label'       => $now->format('F Y'),
            'chart_mode' => $chartMode,
            'week_offset' => $chartMode === 'week' ? $weekOffset : 0,
            'chart_start' => $chartStart->toDateString(),
            'chart_end' => $chartEnd->toDateString(),
        ];

        return response()->json($data)
            ->header('Cache-Control', 'no-cache, no-store, must-revalidate');
    }

    /**
     * Get all customers with pagination
     */
    public function getCustomers(Request $request)
    {
        $this->ensureAdmin($request);
        $amountExpression = $this->orderAmountExpression();
        $customerGroupExpression = $this->orderCustomerGroupExpression();

        $perPage = min((int)$request->query('per_page', 20), 100);
        $searchTerm = trim((string) $request->query('search', ''));
        $searchTerm = preg_replace('/\s+/', ' ', $searchTerm);
        $searchTerm = trim((string) $searchTerm);
        $searchPhone = preg_replace('/\D+/', '', $searchTerm);

        $query = User::whereRaw('LOWER(role) = ?', ['customer']);

        if ($searchTerm) {
            $loweredSearch = mb_strtolower($searchTerm);
            $query->where(function ($q) use ($loweredSearch, $searchPhone) {
                $q->whereRaw('LOWER(name) LIKE ?', ['%' . $loweredSearch . '%'])
                  ->orWhereRaw('LOWER(email) LIKE ?', ['%' . $loweredSearch . '%']);

                if ($searchPhone !== '') {
                    $q->orWhereRaw(
                        "REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phone,' ',''),'-',''),'(',''),')',''),'+','') LIKE ?",
                        ['%' . $searchPhone . '%']
                    );
                }
            });
        }

        $paginated = $query->latest()->paginate($perPage);

        $userIds = collect($paginated->items())->pluck('id')->all();
        $spendByUser = collect();
        $ordersCountByUser = collect();
        if (!empty($userIds)) {
            $spendByUser = DB::table('orders')
                ->selectRaw("{$customerGroupExpression} as customer_id, COALESCE(SUM({$amountExpression}), 0) as total_spent")
                ->whereRaw("{$customerGroupExpression} IN (" . implode(',', array_fill(0, count($userIds), '?')) . ")", $userIds)
                ->where(function ($statusQuery) {
                    $statusQuery->whereNull('status')
                        ->orWhereRaw('LOWER(status) <> ?', ['cancelled']);
                })
                ->groupBy(DB::raw($customerGroupExpression))
                ->pluck('total_spent', 'customer_id');

            $ordersCountByUser = DB::table('orders')
                ->selectRaw("{$customerGroupExpression} as customer_id, COUNT(*) as orders_count")
                ->whereRaw("{$customerGroupExpression} IN (" . implode(',', array_fill(0, count($userIds), '?')) . ")", $userIds)
                ->groupBy(DB::raw($customerGroupExpression))
                ->pluck('orders_count', 'customer_id');
        }

        $customers = $paginated->map(fn ($user) => [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'profile_picture_url' => $user->profile_picture_url,
            'loyalty_points' => (int) ($user->loyalty_points ?? 0),
            'orders_count' => (int) ($ordersCountByUser[$user->id] ?? 0),
            'total_spent' => (float) ($spendByUser[$user->id] ?? 0),
            'email_verified_at' => $user->email_verified_at,
            'created_at' => $user->created_at,
        ]);

        return response()->json([
            'data' => $customers,
            'pagination' => [
                'total' => $paginated->total(),
                'count' => $paginated->count(),
                'per_page' => $paginated->perPage(),
                'current_page' => $paginated->currentPage(),
                'last_page' => $paginated->lastPage(),
            ],
        ]);
    }

    /**
     * Get customer profile details
     */
    public function getCustomerProfile(Request $request, $userId)
    {
        $this->ensureAdmin($request);
        $amountExpression = $this->orderAmountExpression();
        $customerGroupExpression = $this->orderCustomerGroupExpression();

        $customer = User::whereRaw('LOWER(role) = ?', ['customer'])->findOrFail($userId);

        $orderStats = DB::table('orders')
            ->selectRaw(
                "COUNT(*) as orders_count, COALESCE(SUM(CASE WHEN status IS NULL OR LOWER(status) <> 'cancelled' THEN {$amountExpression} ELSE 0 END), 0) as total_spent"
            )
            ->whereRaw("{$customerGroupExpression} = ?", [$customer->id])
            ->first();

        $ordersCount = (int) ($orderStats->orders_count ?? 0);
        $totalSpent = (float) ($orderStats->total_spent ?? 0);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $customer->id,
                'name' => $customer->name,
                'email' => $customer->email,
                'phone' => $customer->phone,
                'profile_picture_url' => $customer->profile_picture_url,
                'bio' => $customer->bio,
                'address' => $customer->address,
                'city' => $customer->city,
                'zip_code' => $customer->zip_code,
                'country' => $customer->country,
                'date_of_birth' => $customer->date_of_birth,
                'gender' => $customer->gender,
                'preferred_language' => $customer->preferred_language,
                'notifications_enabled' => $customer->notifications_enabled,
                'loyalty_points' => (int) ($customer->loyalty_points ?? 0),
                'email_verified_at' => $customer->email_verified_at,
                'profile_completed_at' => $customer->profile_completed_at,
                'orders_count' => $ordersCount,
                'total_spent' => $totalSpent,
                'created_at' => $customer->created_at,
                'last_login_at' => $customer->last_login_at,
            ],
        ]);
    }

    /**
     * Update customer profile as admin
     */
    public function updateCustomerProfile(Request $request, $userId)
    {
        $this->ensureAdmin($request);

        $customer = User::whereRaw('LOWER(role) = ?', ['customer'])->findOrFail($userId);

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255', 'regex:/^[A-Za-z.\s]+$/'],
            'first_name' => ['sometimes', 'required_with:last_name,middle_initial', 'string', 'max:255', 'regex:/\S/'],
            'last_name' => ['sometimes', 'required_with:first_name,middle_initial', 'string', 'max:255', 'regex:/\S/'],
            'middle_initial' => ['sometimes', 'nullable', 'string', 'size:1', 'regex:/^[A-Za-z]$/'],
            'email' => 'sometimes|nullable|email|max:255|unique:users,email,' . $customer->id,
            'phone' => 'sometimes|nullable|string|max:11|regex:/^\d{1,11}$/',
            'bio' => 'sometimes|nullable|string|max:500',
            'address' => 'sometimes|nullable|string|max:255',
            'city' => 'sometimes|nullable|string|max:100',
            'zip_code' => 'sometimes|nullable|string|max:4|regex:/^\d{1,4}$/',
            'country' => 'sometimes|nullable|string|max:100',
            'date_of_birth' => 'sometimes|nullable|date|before:today',
            'gender' => 'sometimes|nullable|in:male,female,other',
            'preferred_language' => 'sometimes|string|in:en,es,fr,de',
            'notifications_enabled' => 'sometimes|boolean',
            'email_verified_at' => 'sometimes|nullable|date',
        ]);

        if (
            array_key_exists('first_name', $validated)
            || array_key_exists('last_name', $validated)
            || array_key_exists('middle_initial', $validated)
        ) {
            $validated['name'] = $this->formatDisplayName(
                $validated['first_name'] ?? '',
                $validated['last_name'] ?? '',
                $validated['middle_initial'] ?? null,
            );
        }

        unset($validated['first_name'], $validated['last_name'], $validated['middle_initial']);

        $customer->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Customer profile updated successfully',
            'data' => [
                'id' => $customer->id,
                'name' => $customer->name,
                'email' => $customer->email,
                'phone' => $customer->phone,
                'bio' => $customer->bio,
                'address' => $customer->address,
                'city' => $customer->city,
                'zip_code' => $customer->zip_code,
                'country' => $customer->country,
                'date_of_birth' => $customer->date_of_birth,
                'gender' => $customer->gender,
                'preferred_language' => $customer->preferred_language,
                'notifications_enabled' => $customer->notifications_enabled,
                'loyalty_points' => (int) ($customer->loyalty_points ?? 0),
                'email_verified_at' => $customer->email_verified_at,
            ],
        ]);
    }

    /**
     * Get all orders for a customer
     */
    public function getCustomerOrders(Request $request, $userId)
    {
        $this->ensureAdmin($request);

        $customer = User::whereRaw('LOWER(role) = ?', ['customer'])->findOrFail($userId);
        $perPage = min((int)$request->query('per_page', 20), 100);
        $customerGroupExpression = $this->orderCustomerGroupExpression();

        $paginated = Order::query()
            ->whereRaw("{$customerGroupExpression} = ?", [$customer->id])
            ->with(['service'])
            ->latest()
            ->paginate($perPage);

        $orders = $paginated->map(fn ($order) => [
            'order_id' => $order->id,
            'id' => '#LH-' . str_pad($order->id, 3, '0', STR_PAD_LEFT),
            'service_type' => $order->service?->name ?? 'Unknown Service',
            'service_emoji' => $this->getServiceEmoji($order->service?->name ?? ''),
            'weight_kg' => (int)$order->weight_kg,
            'pickup_address' => $order->pickup_address,
            'pickup_date' => $order->pickup_date,
            'delivery_date' => $order->delivery_date,
            'delivery_type' => $order->delivery_type ?? 'pickup',
            'type' => $order->type ?? (($order->delivery_type ?? 'pickup') === 'delivery' ? 'dropoff' : 'pickup'),
            'delivery_fee' => (float) ($order->delivery_fee ?? 0),
            'laundry_photo' => $order->laundry_photo,
            'laundry_photo_url' => $order->laundry_photo ? asset($order->laundry_photo) : null,
            'total_price' => $order->total_price,
            'status' => ucfirst($order->status),
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
}

