<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Api\AdminController as ApiAdminController;
use App\Http\Controllers\Controller;
use App\Models\AddOnService;
use App\Models\Order;
use App\Models\Service;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class AdminWebController extends Controller
{
    private const ADMIN_BRIDGE_LOGIN_CACHE_PREFIX = 'admin_bridge_login:';
    private const ORDER_STATUSES = ['pending', 'ongoing', 'ready', 'completed', 'cancelled'];

    public function bridgeLogin(Request $request): RedirectResponse
    {
        $token = trim((string) $request->query('token', ''));
        if ($token === '') {
            return redirect()
                ->route('login')
                ->withErrors(['email' => 'Invalid admin redirect link. Please sign in again from the app.']);
        }

        $userId = Cache::pull($this->adminBridgeLoginCacheKey($token));
        if (! is_numeric($userId)) {
            return redirect()
                ->route('login')
                ->withErrors(['email' => 'Admin redirect link expired. Please sign in again from the app.']);
        }

        $admin = User::find((int) $userId);
        if (! $admin instanceof User || ! $admin->isAdmin()) {
            return redirect()
                ->route('login')
                ->withErrors(['email' => 'Admin redirect is no longer valid. Please sign in again.']);
        }

        Auth::login($admin);
        $request->session()->regenerate();

        return redirect()->route('admin.dashboard');
    }

    public function dashboard(Request $request): View
    {
        $statusFilter = strtolower((string) $request->query('status', 'all'));
        if (! in_array($statusFilter, array_merge(['all'], self::ORDER_STATUSES), true)) {
            $statusFilter = 'all';
        }

        $today = Carbon::today();

        $stats = [
            'total_bookings' => Order::count(),
            'pending_count' => Order::where('status', 'pending')->count(),
            'revenue_today' => (float) Order::whereDate('created_at', $today)
                ->where('status', '!=', 'cancelled')
                ->sum('total_price'),
            'customer_count' => User::where('role', 'customer')->count(),
        ];

        $recentOrders = Order::with(['user', 'service'])
            ->latest()
            ->take(6)
            ->get();

        $ordersQuery = Order::with(['user', 'service'])->latest();
        if ($statusFilter !== 'all') {
            $ordersQuery->where('status', $statusFilter);
        }

        $orders = $ordersQuery
            ->paginate(10)
            ->withQueryString();

        $topCustomers = User::where('role', 'customer')
            ->whereHas('orders')
            ->withCount('orders')
            ->withSum(
                ['orders as total_spent' => fn ($query) => $query->where('status', '!=', 'cancelled')],
                'total_price'
            )
            ->orderByDesc('total_spent')
            ->limit(5)
            ->get();

        $customers = User::where('role', 'customer')
            ->withCount('orders')
            ->withSum(
                ['orders as total_spent' => fn ($query) => $query->where('status', '!=', 'cancelled')],
                'total_price'
            )
            ->latest()
            ->take(10)
            ->get();

        $services = Service::orderBy('name')->get();

        $addOnServiceFilter = strtolower((string) $request->query('add_on_service_filter', 'all'));
        $addOnActiveFilter = strtolower((string) $request->query('add_on_active_filter', 'all'));

        if (! in_array($addOnActiveFilter, ['all', 'active', 'inactive'], true)) {
            $addOnActiveFilter = 'all';
        }

        $serviceFilterIds = $services
            ->pluck('id')
            ->map(static fn ($id) => (string) $id)
            ->all();

        if ($addOnServiceFilter === '') {
            $addOnServiceFilter = 'all';
        }

        if ($addOnServiceFilter !== 'all'
            && $addOnServiceFilter !== 'global'
            && ! in_array($addOnServiceFilter, $serviceFilterIds, true)) {
            $addOnServiceFilter = 'all';
        }

        $addOnQuery = AddOnService::with('service')->orderBy('name');

        if ($addOnServiceFilter === 'global') {
            $addOnQuery->whereNull('service_id');
        } elseif (ctype_digit($addOnServiceFilter)) {
            $addOnQuery->where('service_id', (int) $addOnServiceFilter);
        }

        if ($addOnActiveFilter === 'active') {
            $addOnQuery->where('is_active', true);
        } elseif ($addOnActiveFilter === 'inactive') {
            $addOnQuery->where('is_active', false);
        }

        $addOnServices = $addOnQuery
            ->paginate(8, ['*'], 'add_on_page')
            ->withQueryString();

        $addOnFilterParams = [
            'status' => $statusFilter,
            'add_on_service_filter' => $addOnServiceFilter,
            'add_on_active_filter' => $addOnActiveFilter,
            'add_on_page' => $addOnServices->currentPage(),
        ];

        $analytics = $this->buildAnalytics();

        return view('admin.dashboard', [
            'stats' => $stats,
            'recentOrders' => $recentOrders,
            'orders' => $orders,
            'statusFilter' => $statusFilter,
            'orderStatuses' => self::ORDER_STATUSES,
            'topCustomers' => $topCustomers,
            'customers' => $customers,
            'services' => $services,
            'addOnServices' => $addOnServices,
            'addOnServiceFilter' => $addOnServiceFilter,
            'addOnActiveFilter' => $addOnActiveFilter,
            'addOnFilterParams' => $addOnFilterParams,
            'analytics' => $analytics,
        ]);
    }

    public function updateOrderStatus(Request $request, Order $order): RedirectResponse
    {
        $validated = $request->validate([
            'status' => ['required', Rule::in(self::ORDER_STATUSES)],
            'status_filter' => ['nullable', Rule::in(array_merge(['all'], self::ORDER_STATUSES))],
            'page' => ['nullable', 'integer', 'min:1'],
        ]);

        // Reuse API admin logic to keep notifications, cache behavior, and points handling identical.
        app(ApiAdminController::class)->updateOrderStatus($request, $order);

        $statusFilter = $validated['status_filter'] ?? 'all';
        $page = $validated['page'] ?? null;

        $params = ['status' => $statusFilter];
        if ($page !== null) {
            $params['page'] = $page;
        }

        return redirect()
            ->route('admin.dashboard', $params)
            ->with('status', 'Order status updated successfully.');
    }

    public function storeService(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:1000'],
            'price_per_kg' => ['required', 'numeric', 'min:0'],
            'category' => ['nullable', 'string', 'max:100'],
            'image_url' => ['nullable', 'url', 'max:500'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $validated['is_active'] = (bool) ($validated['is_active'] ?? false);

        Service::create($validated);

        return redirect()
            ->route('admin.dashboard', ['status' => request('status', 'all')])
            ->with('status', 'Service created successfully.');
    }

    public function updateService(Request $request, Service $service): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:1000'],
            'price_per_kg' => ['required', 'numeric', 'min:0'],
            'category' => ['nullable', 'string', 'max:100'],
            'image_url' => ['nullable', 'url', 'max:500'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $validated['is_active'] = (bool) ($validated['is_active'] ?? false);

        $service->update($validated);

        return redirect()
            ->route('admin.dashboard', ['status' => request('status', 'all')])
            ->with('status', 'Service updated successfully.');
    }

    public function destroyService(Service $service): RedirectResponse
    {
        $service->delete();

        return redirect()
            ->route('admin.dashboard', ['status' => request('status', 'all')])
            ->with('status', 'Service deleted successfully.');
    }

    public function storeAddOnService(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'service_id' => ['nullable', 'integer', 'exists:services,id'],
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:1000'],
            'fee' => ['required', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $validated['is_active'] = (bool) ($validated['is_active'] ?? false);

        AddOnService::create($validated);

        return redirect()
            ->route('admin.dashboard', $this->addOnRedirectParams($request))
            ->with('status', 'Add-on service created successfully.');
    }

    public function updateAddOnService(Request $request, AddOnService $addOnService): RedirectResponse
    {
        $validated = $request->validate([
            'service_id' => ['nullable', 'integer', 'exists:services,id'],
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:1000'],
            'fee' => ['required', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $validated['is_active'] = (bool) ($validated['is_active'] ?? false);

        $addOnService->update($validated);

        return redirect()
            ->route('admin.dashboard', $this->addOnRedirectParams($request))
            ->with('status', 'Add-on service updated successfully.');
    }

    public function destroyAddOnService(Request $request, AddOnService $addOnService): RedirectResponse
    {
        $addOnService->delete();

        return redirect()
            ->route('admin.dashboard', $this->addOnRedirectParams($request))
            ->with('status', 'Add-on service deleted successfully.');
    }

    private function addOnRedirectParams(Request $request): array
    {
        $params = [
            'status' => $request->input('status', $request->query('status', 'all')),
        ];

        $serviceFilter = $request->input('add_on_service_filter', $request->query('add_on_service_filter'));
        if ($serviceFilter !== null && $serviceFilter !== '') {
            $params['add_on_service_filter'] = $serviceFilter;
        }

        $activeFilter = $request->input('add_on_active_filter', $request->query('add_on_active_filter'));
        if ($activeFilter !== null && $activeFilter !== '') {
            $params['add_on_active_filter'] = $activeFilter;
        }

        $addOnPage = $request->input('add_on_page', $request->query('add_on_page'));
        if ($addOnPage !== null && $addOnPage !== '') {
            $params['add_on_page'] = $addOnPage;
        }

        return $params;
    }

    private function buildAnalytics(): array
    {
        $now = Carbon::now();
        $weekStart = $now->copy()->startOfWeek(Carbon::MONDAY);

        $weeklyRevenue = [];
        for ($dayOffset = 0; $dayOffset < 7; $dayOffset++) {
            $day = $weekStart->copy()->addDays($dayOffset);
            $weeklyRevenue[] = (float) Order::whereDate('created_at', $day)
                ->where('status', '!=', 'cancelled')
                ->sum('total_price');
        }

        $serviceCounts = Order::select(
            DB::raw('services.name as service_name'),
            DB::raw('COUNT(*) as order_count')
        )
            ->join('services', 'orders.service_id', '=', 'services.id')
            ->where('orders.status', '!=', 'cancelled')
            ->groupBy('services.id', 'services.name')
            ->orderByDesc('order_count')
            ->get();

        $totalOrders = (int) $serviceCounts->sum('order_count');
        $serviceBreakdown = [];
        $othersCount = 0;

        foreach ($serviceCounts as $index => $row) {
            if ($index < 4) {
                $count = (int) $row->order_count;
                $serviceBreakdown[] = [
                    'name' => (string) $row->service_name,
                    'count' => $count,
                    'pct' => $totalOrders > 0 ? (int) round(($count / $totalOrders) * 100) : 0,
                ];
            } else {
                $othersCount += (int) $row->order_count;
            }
        }

        if ($othersCount > 0) {
            $serviceBreakdown[] = [
                'name' => 'Others',
                'count' => $othersCount,
                'pct' => $totalOrders > 0 ? (int) round(($othersCount / $totalOrders) * 100) : 0,
            ];
        }

        $monthlyRevenue = (float) Order::whereMonth('created_at', $now->month)
            ->whereYear('created_at', $now->year)
            ->where('status', '!=', 'cancelled')
            ->sum('total_price');

        return [
            'weekly_revenue' => $weeklyRevenue,
            'service_breakdown' => $serviceBreakdown,
            'monthly_revenue' => $monthlyRevenue,
            'month_label' => $now->format('F Y'),
        ];
    }

    private function adminBridgeLoginCacheKey(string $token): string
    {
        return self::ADMIN_BRIDGE_LOGIN_CACHE_PREFIX.$token;
    }
}
