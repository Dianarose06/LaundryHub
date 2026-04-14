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
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
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

        // Don't cache - return fresh data to avoid stale prices
        $orders = Order::with(['user', 'service'])
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
                'total_price' => (float)$order->total_price,  // Ensure float for consistency
                'status'   => ucfirst($order->status),
            ]);

        return response()->json(['data' => $orders])
            ->header('Cache-Control', 'no-cache, no-store, must-revalidate');
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
            'weight_kg' => (float)$order->weight_kg,
            'pickup_address' => $order->pickup_address,
            'pickup_date' => $order->pickup_date,
            'delivery_date' => $order->delivery_date,
            'delivery_type' => $order->delivery_type ?? 'pickup',
            'total_price' => (float)$order->total_price,
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

        $previousStatus = $order->status;
        $nextStatus = $validated['status'];
        $awardedPoints = 0;

        if ($previousStatus !== $nextStatus) {
            $order->update(['status' => $nextStatus]);

            $this->sendOrderStatusEmail($order, $previousStatus, $nextStatus);

            if ($nextStatus === 'ready') {
                if (($order->delivery_type ?? 'pickup') === 'delivery') {
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

    /**
     * Get all customers with pagination
     */
    public function getCustomers(Request $request)
    {
        $this->ensureAdmin($request);

        $perPage = min((int)$request->query('per_page', 20), 100);
        $searchTerm = $request->query('search');

        $query = User::where('role', 'customer');

        if ($searchTerm) {
            $query->where(function ($q) use ($searchTerm) {
                $q->where('name', 'like', "%{$searchTerm}%")
                  ->orWhere('email', 'like', "%{$searchTerm}%")
                  ->orWhere('phone', 'like', "%{$searchTerm}%");
            });
        }

        $paginated = $query->withCount('orders')
            ->withSum(['orders' => fn ($q) => $q->where('status', '!=', 'cancelled')], 'total_price')
            ->latest()
            ->paginate($perPage);

        $customers = $paginated->map(fn ($user) => [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'profile_picture_url' => $user->profile_picture_url,
            'loyalty_points' => (int) ($user->loyalty_points ?? 0),
            'orders_count' => $user->orders_count,
            'total_spent' => $user->orders_sum_total_price ?? 0,
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

        $customer = User::where('role', 'customer')->findOrFail($userId);

        $ordersCount = $customer->orders()->count();
        $totalSpent = (float) $customer->orders()
            ->where('status', '!=', 'cancelled')
            ->sum('total_price');

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

        $customer = User::where('role', 'customer')->findOrFail($userId);

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255', 'regex:/\S/'],
            'first_name' => ['sometimes', 'required_with:last_name,middle_initial', 'string', 'max:255', 'regex:/\S/'],
            'last_name' => ['sometimes', 'required_with:first_name,middle_initial', 'string', 'max:255', 'regex:/\S/'],
            'middle_initial' => ['sometimes', 'nullable', 'string', 'size:1', 'regex:/^[A-Za-z]$/'],
            'phone' => 'sometimes|nullable|string|max:20|regex:/^[0-9\s\-\+\(\)]+$/',
            'bio' => 'sometimes|nullable|string|max:500',
            'address' => 'sometimes|nullable|string|max:255',
            'city' => 'sometimes|nullable|string|max:100',
            'zip_code' => 'sometimes|nullable|string|max:20',
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

        $customer = User::where('role', 'customer')->findOrFail($userId);
        $perPage = min((int)$request->query('per_page', 20), 100);

        $paginated = $customer->orders()
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