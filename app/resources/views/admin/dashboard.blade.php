@php
    $statusLabels = [
        'pending' => 'Pending',
        'ongoing' => 'Ongoing',
        'ready' => 'Ready',
        'completed' => 'Completed',
        'cancelled' => 'Cancelled',
    ];
    $chartDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    $weeklyRevenue = $analytics['weekly_revenue'] ?? [];
    $maxWeeklyRevenue = max($weeklyRevenue ?: [0]);
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LaundryHub Admin Panel</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Public+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --navy: #0f172a;
            --ink: #1e293b;
            --muted: #64748b;
            --bg: #ecf3ff;
            --card: #ffffff;
            --line: #dbeafe;
            --primary: #2563eb;
            --primary-2: #1d4ed8;
            --accent: #14b8a6;
            --danger: #ef4444;
            --warning: #f59e0b;
            --ok: #16a34a;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            color: var(--ink);
            background:
                radial-gradient(1200px 500px at -10% -10%, #bfdbfe 0%, transparent 65%),
                radial-gradient(900px 500px at 110% -20%, #a7f3d0 0%, transparent 58%),
                var(--bg);
            font-family: 'Public Sans', system-ui, sans-serif;
        }

        .shell {
            width: min(1320px, calc(100% - 28px));
            margin: 14px auto 26px;
        }

        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: linear-gradient(125deg, #0f172a, #1d4ed8 56%, #0ea5e9 100%);
            color: #fff;
            border-radius: 20px;
            padding: 20px 22px;
            box-shadow: 0 20px 50px rgba(15, 23, 42, 0.26);
        }

        .brand {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .brand strong {
            font-family: 'Outfit', system-ui, sans-serif;
            font-size: 26px;
            font-weight: 700;
            letter-spacing: 0.2px;
        }

        .brand p {
            margin: 0;
            color: rgba(255, 255, 255, 0.82);
            font-size: 14px;
        }

        .topbar-nav {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-right: 14px;
        }

        .topbar-nav a {
            color: #dbeafe;
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
            padding: 8px 11px;
            border-radius: 10px;
            border: 1px solid rgba(147, 197, 253, 0.35);
            background: rgba(15, 23, 42, 0.22);
        }

        .topbar-nav a:hover {
            background: rgba(255, 255, 255, 0.12);
        }

        .logout-btn {
            border: 0;
            border-radius: 12px;
            background: #ef4444;
            color: #fff;
            font-size: 13px;
            font-weight: 800;
            padding: 10px 14px;
            cursor: pointer;
        }

        .logout-btn:hover {
            background: #dc2626;
        }

        .flash {
            margin-top: 16px;
            background: #dcfce7;
            border: 1px solid #86efac;
            color: #14532d;
            border-radius: 12px;
            padding: 11px 13px;
            font-weight: 600;
            font-size: 14px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(12, minmax(0, 1fr));
            gap: 14px;
            margin-top: 16px;
        }

        .card {
            background: var(--card);
            border: 1px solid var(--line);
            border-radius: 18px;
            box-shadow: 0 12px 34px rgba(37, 99, 235, 0.08);
            padding: 18px;
        }

        .title {
            margin: 0 0 6px;
            font-family: 'Outfit', system-ui, sans-serif;
            color: var(--navy);
            letter-spacing: 0.2px;
        }

        .sub {
            margin: 0;
            color: var(--muted);
            font-size: 13px;
        }

        .kpi {
            grid-column: span 3;
            padding: 16px;
        }

        .kpi .value {
            margin-top: 8px;
            font-family: 'Outfit', system-ui, sans-serif;
            font-size: 28px;
            font-weight: 800;
            color: var(--navy);
        }

        .kpi .label {
            color: var(--muted);
            font-size: 13px;
            font-weight: 700;
        }

        .wide {
            grid-column: span 8;
        }

        .side {
            grid-column: span 4;
        }

        .full {
            grid-column: span 12;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 12px;
        }

        th,
        td {
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
            padding: 10px 7px;
            font-size: 13px;
            vertical-align: top;
        }

        th {
            color: #475569;
            font-size: 11px;
            letter-spacing: 0.45px;
            text-transform: uppercase;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            padding: 4px 10px;
            font-size: 11px;
            font-weight: 700;
            border: 1px solid transparent;
        }

        .pending {
            background: #fffbeb;
            color: #92400e;
            border-color: #fcd34d;
        }

        .ongoing {
            background: #eff6ff;
            color: #1d4ed8;
            border-color: #93c5fd;
        }

        .ready {
            background: #ecfeff;
            color: #0f766e;
            border-color: #67e8f9;
        }

        .completed {
            background: #f0fdf4;
            color: #166534;
            border-color: #86efac;
        }

        .cancelled {
            background: #fef2f2;
            color: #991b1b;
            border-color: #fca5a5;
        }

        .filter-pills {
            margin-top: 12px;
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .pill {
            text-decoration: none;
            color: #334155;
            background: #f8fafc;
            border: 1px solid #cbd5e1;
            padding: 6px 11px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 700;
        }

        .pill.active {
            color: #fff;
            border-color: var(--primary);
            background: linear-gradient(120deg, var(--primary), var(--primary-2));
        }

        .inline-form {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }

        select,
        input[type="text"],
        input[type="number"],
        input[type="url"] {
            width: 100%;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            padding: 8px 9px;
            font-size: 13px;
            color: #0f172a;
            background: #fff;
        }

        .inline-form select {
            width: 116px;
        }

        .btn {
            border: 0;
            border-radius: 10px;
            padding: 8px 11px;
            font-size: 12px;
            font-weight: 800;
            cursor: pointer;
        }

        .btn.primary {
            background: var(--primary);
            color: #fff;
        }

        .btn.primary:hover {
            background: var(--primary-2);
        }

        .btn.soft {
            background: #e2e8f0;
            color: #0f172a;
        }

        .btn.danger {
            background: #fee2e2;
            color: #991b1b;
        }

        .btn.danger:hover {
            background: #fecaca;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(6, minmax(0, 1fr));
            gap: 8px;
            margin-top: 12px;
        }

        .add-on-filters {
            margin-top: 12px;
            display: grid;
            gap: 8px;
        }

        .add-on-filters .filter-grid {
            display: grid;
            grid-template-columns: minmax(220px, 2fr) minmax(160px, 1fr) auto;
            gap: 8px;
            align-items: center;
        }

        .service-grid {
            margin-top: 12px;
            display: grid;
            gap: 10px;
        }

        .service-item {
            border: 1px solid #dbeafe;
            border-radius: 12px;
            padding: 10px;
            background: #f8fbff;
        }

        .service-item .row {
            display: grid;
            grid-template-columns: 2fr 1.2fr 1.2fr 2fr auto;
            gap: 8px;
            align-items: center;
        }

        .service-item .actions {
            display: flex;
            gap: 7px;
            align-items: center;
        }

        .add-on-item {
            border: 1px solid #dbeafe;
            border-radius: 12px;
            padding: 10px;
            background: #f8fbff;
        }

        .add-on-item .row {
            display: grid;
            grid-template-columns: 2fr 1.2fr 2fr auto;
            gap: 8px;
            align-items: center;
        }

        .add-on-item .actions {
            display: flex;
            gap: 7px;
            align-items: center;
        }

        .mini {
            font-size: 11px;
            color: #64748b;
            margin-top: 4px;
        }

        .bars {
            margin-top: 16px;
            height: 180px;
            display: flex;
            align-items: flex-end;
            gap: 10px;
        }

        .bar-wrap {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
        }

        .bar {
            width: 100%;
            border-radius: 12px 12px 6px 6px;
            background: linear-gradient(180deg, #38bdf8 0%, #2563eb 100%);
            min-height: 8px;
        }

        .bar-label {
            font-size: 11px;
            color: #475569;
            font-weight: 700;
        }

        .bar-value {
            font-size: 10px;
            color: #0369a1;
            font-weight: 700;
        }

        .service-breakdown {
            margin-top: 12px;
            display: grid;
            gap: 8px;
        }

        .service-breakdown .item {
            border-radius: 10px;
            border: 1px solid #bfdbfe;
            background: #eff6ff;
            padding: 9px 10px;
            display: flex;
            justify-content: space-between;
            font-size: 13px;
            font-weight: 700;
            color: #1e3a8a;
        }

        .pager {
            margin-top: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .pager a {
            text-decoration: none;
            color: #1d4ed8;
            font-weight: 700;
            font-size: 13px;
            border: 1px solid #bfdbfe;
            border-radius: 8px;
            padding: 6px 9px;
            background: #eff6ff;
        }

        @media (max-width: 1120px) {
            .kpi {
                grid-column: span 6;
            }

            .wide,
            .side {
                grid-column: span 12;
            }

            .service-item .row {
                grid-template-columns: 1fr;
            }

            .add-on-item .row {
                grid-template-columns: 1fr;
            }

            .form-grid {
                grid-template-columns: 1fr 1fr;
            }

            .add-on-filters .filter-grid {
                grid-template-columns: 1fr;
            }

            .topbar {
                flex-direction: column;
                align-items: flex-start;
                gap: 14px;
            }
        }

        @media (max-width: 720px) {
            .shell {
                width: calc(100% - 14px);
                margin: 8px auto 16px;
            }

            .card {
                padding: 14px;
                border-radius: 14px;
            }

            .kpi {
                grid-column: span 12;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="shell">
        <header class="topbar">
            <div class="brand">
                <strong>LaundryHub Admin</strong>
                <p>Welcome back, {{ auth()->user()->name }}. Manage orders, services, customers, and analytics.</p>
            </div>

            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                <nav class="topbar-nav">
                    <a href="#overview">Overview</a>
                    <a href="#bookings">Bookings</a>
                    <a href="#services">Services</a>
                    <a href="#add-ons">Add-ons</a>
                    <a href="#customers">Customers</a>
                    <a href="#analytics">Analytics</a>
                </nav>

                <form method="POST" action="{{ route('logout') }}">
                    @csrf
                    <button type="submit" class="logout-btn">Logout</button>
                </form>
            </div>
        </header>

        @if (session('status'))
            <div class="flash">{{ session('status') }}</div>
        @endif

        <section id="overview" class="grid">
            <article class="card kpi">
                <div class="label">Total Bookings</div>
                <div class="value">{{ number_format((int) $stats['total_bookings']) }}</div>
            </article>
            <article class="card kpi">
                <div class="label">Pending Orders</div>
                <div class="value">{{ number_format((int) $stats['pending_count']) }}</div>
            </article>
            <article class="card kpi">
                <div class="label">Revenue Today</div>
                <div class="value">P{{ number_format((float) $stats['revenue_today'], 2) }}</div>
            </article>
            <article class="card kpi">
                <div class="label">Customers</div>
                <div class="value">{{ number_format((int) $stats['customer_count']) }}</div>
            </article>

            <article class="card wide">
                <h2 class="title">Recent Bookings</h2>
                <p class="sub">Latest booking activity from your LaundryHub customers.</p>

                <table>
                    <thead>
                        <tr>
                            <th>Order</th>
                            <th>Customer</th>
                            <th>Service</th>
                            <th>Status</th>
                            <th>Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($recentOrders as $order)
                            <tr>
                                <td>#LH-{{ str_pad((string) $order->id, 3, '0', STR_PAD_LEFT) }}</td>
                                <td>{{ $order->user?->name ?? 'Unknown' }}</td>
                                <td>{{ $order->service?->name ?? 'Unknown Service' }}</td>
                                <td>
                                    @php $rowStatus = strtolower((string) $order->status); @endphp
                                    <span class="badge {{ $rowStatus }}">{{ $statusLabels[$rowStatus] ?? ucfirst($rowStatus) }}</span>
                                </td>
                                <td>P{{ number_format((float) $order->total_price, 2) }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5">No bookings yet.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </article>

            <article class="card side">
                <h2 class="title">Top Customers</h2>
                <p class="sub">Highest spenders (excluding cancelled orders).</p>

                <div style="margin-top: 10px; display: grid; gap: 9px;">
                    @forelse ($topCustomers as $customer)
                        <div style="padding: 9px 10px; border: 1px solid #c7d2fe; border-radius: 10px; background: #f8faff;">
                            <div style="font-weight: 700; color: #1e1b4b;">{{ $customer->name }}</div>
                            <div class="mini">
                                {{ (int) $customer->orders_count }} orders
                                | P{{ number_format((float) ($customer->total_spent ?? 0), 2) }}
                            </div>
                        </div>
                    @empty
                        <div class="mini">No customer activity yet.</div>
                    @endforelse
                </div>
            </article>
        </section>

        <section id="bookings" class="grid">
            <article class="card full">
                <h2 class="title">Bookings Management</h2>
                <p class="sub">Filter orders and update the status directly from your browser admin panel.</p>

                <div class="filter-pills">
                    <a class="pill {{ $statusFilter === 'all' ? 'active' : '' }}" href="{{ route('admin.dashboard', ['status' => 'all']) }}#bookings">All</a>
                    @foreach ($orderStatuses as $status)
                        <a class="pill {{ $statusFilter === $status ? 'active' : '' }}" href="{{ route('admin.dashboard', ['status' => $status]) }}#bookings">
                            {{ $statusLabels[$status] ?? ucfirst($status) }}
                        </a>
                    @endforeach
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>Order</th>
                            <th>Customer</th>
                            <th>Service</th>
                            <th>Weight</th>
                            <th>Total</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($orders as $order)
                            @php $rowStatus = strtolower((string) $order->status); @endphp
                            <tr>
                                <td>#LH-{{ str_pad((string) $order->id, 3, '0', STR_PAD_LEFT) }}</td>
                                <td>{{ $order->user?->name ?? 'Unknown' }}</td>
                                <td>{{ $order->service?->name ?? 'Unknown Service' }}</td>
                                <td>{{ number_format((float) $order->weight_kg, 2) }} kg</td>
                                <td>P{{ number_format((float) $order->total_price, 2) }}</td>
                                <td><span class="badge {{ $rowStatus }}">{{ $statusLabels[$rowStatus] ?? ucfirst($rowStatus) }}</span></td>
                                <td>
                                    <form class="inline-form" method="POST" action="{{ route('admin.orders.status', $order) }}">
                                        @csrf
                                        @method('PATCH')
                                        <input type="hidden" name="status_filter" value="{{ $statusFilter }}">
                                        <input type="hidden" name="page" value="{{ $orders->currentPage() }}">
                                        <select name="status">
                                            @foreach ($orderStatuses as $status)
                                                <option value="{{ $status }}" {{ $rowStatus === $status ? 'selected' : '' }}>
                                                    {{ $statusLabels[$status] ?? ucfirst($status) }}
                                                </option>
                                            @endforeach
                                        </select>
                                        <button class="btn primary" type="submit">Update</button>
                                    </form>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="7">No orders found for this filter.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>

                <div class="pager">
                    <div class="mini">
                        Showing {{ $orders->count() }} of {{ $orders->total() }} order(s)
                    </div>
                    <div style="display: flex; gap: 7px;">
                        @if ($orders->onFirstPage())
                            <span class="mini">Previous</span>
                        @else
                            <a href="{{ $orders->previousPageUrl() }}#bookings">Previous</a>
                        @endif

                        @if ($orders->hasMorePages())
                            <a href="{{ $orders->nextPageUrl() }}#bookings">Next</a>
                        @else
                            <span class="mini">Next</span>
                        @endif
                    </div>
                </div>
            </article>
        </section>

        <section id="services" class="grid">
            <article class="card full">
                <h2 class="title">Services and Pricing</h2>
                <p class="sub">Create, update, and remove service offerings from this web admin panel.</p>

                <form method="POST" action="{{ route('admin.services.store', ['status' => $statusFilter]) }}">
                    @csrf
                    <div class="form-grid">
                        <input type="text" name="name" placeholder="Service name" required>
                        <input type="number" name="price_per_kg" placeholder="Price per kg" min="0" step="0.01" required>
                        <input type="text" name="category" placeholder="Category">
                        <input type="url" name="image_url" placeholder="Image URL (optional)">
                        <input type="text" name="description" placeholder="Description (optional)">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <input type="hidden" name="is_active" value="0">
                            <input id="new_is_active" type="checkbox" name="is_active" value="1" checked>
                            <label for="new_is_active" style="font-size: 12px; color: #334155;">Active</label>
                            <button class="btn primary" type="submit">Add Service</button>
                        </div>
                    </div>
                </form>

                <div class="service-grid">
                    @forelse ($services as $service)
                        <div class="service-item">
                            <form method="POST" action="{{ route('admin.services.update', ['service' => $service, 'status' => $statusFilter]) }}">
                                @csrf
                                @method('PUT')
                                <div class="row">
                                    <input type="text" name="name" value="{{ $service->name }}" required>
                                    <input type="number" name="price_per_kg" min="0" step="0.01" value="{{ number_format((float) $service->price_per_kg, 2, '.', '') }}" required>
                                    <input type="text" name="category" value="{{ $service->category }}" placeholder="Category">
                                    <input type="url" name="image_url" value="{{ $service->image_url }}" placeholder="Image URL">
                                    <div class="actions">
                                        <input type="hidden" name="is_active" value="0">
                                        <label style="display:flex; align-items:center; gap:6px; font-size:12px; color:#334155;">
                                            <input type="checkbox" name="is_active" value="1" {{ $service->is_active ? 'checked' : '' }}>
                                            Active
                                        </label>
                                        <button class="btn primary" type="submit">Save</button>
                                    </div>
                                </div>
                                <input style="margin-top: 8px;" type="text" name="description" value="{{ $service->description }}" placeholder="Description">
                            </form>

                            <form style="margin-top:8px;" method="POST" action="{{ route('admin.services.destroy', ['service' => $service, 'status' => $statusFilter]) }}" onsubmit="return confirm('Delete this service?');">
                                @csrf
                                @method('DELETE')
                                <button class="btn danger" type="submit">Delete Service</button>
                            </form>
                        </div>
                    @empty
                        <div class="mini">No services yet.</div>
                    @endforelse
                </div>
            </article>
        </section>

        <section id="add-ons" class="grid">
            <article class="card full">
                <h2 class="title">Add-on Services</h2>
                <p class="sub">Manage service-specific or global add-ons and pricing for Sprint 6.</p>

                <form method="POST" action="{{ route('admin.add-ons.store', $addOnFilterParams) }}">
                    @csrf
                    <div class="form-grid">
                        <input type="text" name="name" placeholder="Add-on name" required>
                        <input type="number" name="fee" placeholder="Fee" min="0" step="0.01" required>
                        <select name="service_id">
                            <option value="">Global (all eligible services)</option>
                            @foreach ($services as $service)
                                <option value="{{ $service->id }}">{{ $service->name }}</option>
                            @endforeach
                        </select>
                        <input type="text" name="description" placeholder="Description (optional)">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <input type="hidden" name="is_active" value="0">
                            <input id="new_add_on_is_active" type="checkbox" name="is_active" value="1" checked>
                            <label for="new_add_on_is_active" style="font-size: 12px; color: #334155;">Active</label>
                        </div>
                        <div style="display: flex; align-items: center;">
                            <button class="btn primary" type="submit">Add Add-on</button>
                        </div>
                    </div>
                </form>

                <div class="add-on-filters">
                    <form method="GET" action="{{ route('admin.dashboard') }}#add-ons">
                        <input type="hidden" name="status" value="{{ $statusFilter }}">
                        <div class="filter-grid">
                            <select name="add_on_service_filter">
                                <option value="all" {{ $addOnServiceFilter === 'all' ? 'selected' : '' }}>All add-ons</option>
                                <option value="global" {{ $addOnServiceFilter === 'global' ? 'selected' : '' }}>Global only</option>
                                @foreach ($services as $service)
                                    <option value="{{ $service->id }}" {{ (string) $addOnServiceFilter === (string) $service->id ? 'selected' : '' }}>
                                        Only for {{ $service->name }}
                                    </option>
                                @endforeach
                            </select>
                            <select name="add_on_active_filter">
                                <option value="all" {{ $addOnActiveFilter === 'all' ? 'selected' : '' }}>All statuses</option>
                                <option value="active" {{ $addOnActiveFilter === 'active' ? 'selected' : '' }}>Active only</option>
                                <option value="inactive" {{ $addOnActiveFilter === 'inactive' ? 'selected' : '' }}>Inactive only</option>
                            </select>
                            <button class="btn soft" type="submit">Apply Filters</button>
                        </div>
                    </form>
                </div>

                <div class="service-grid">
                    @forelse ($addOnServices as $addOn)
                        <div class="add-on-item">
                            <form method="POST" action="{{ route('admin.add-ons.update', array_merge(['addOnService' => $addOn], $addOnFilterParams)) }}">
                                @csrf
                                @method('PUT')
                                <div class="row">
                                    <input type="text" name="name" value="{{ $addOn->name }}" required>
                                    <input type="number" name="fee" min="0" step="0.01" value="{{ number_format((float) $addOn->fee, 2, '.', '') }}" required>
                                    <select name="service_id">
                                        <option value="">Global (all eligible services)</option>
                                        @foreach ($services as $service)
                                            <option value="{{ $service->id }}" {{ (int) ($addOn->service_id ?? 0) === (int) $service->id ? 'selected' : '' }}>
                                                {{ $service->name }}
                                            </option>
                                        @endforeach
                                    </select>
                                    <div class="actions">
                                        <input type="hidden" name="is_active" value="0">
                                        <label style="display:flex; align-items:center; gap:6px; font-size:12px; color:#334155;">
                                            <input type="checkbox" name="is_active" value="1" {{ $addOn->is_active ? 'checked' : '' }}>
                                            Active
                                        </label>
                                        <button class="btn primary" type="submit">Save</button>
                                    </div>
                                </div>
                                <input style="margin-top: 8px;" type="text" name="description" value="{{ $addOn->description }}" placeholder="Description">
                            </form>

                            <div class="mini">
                                Scope:
                                @if ($addOn->service)
                                    Only for {{ $addOn->service->name }}
                                @else
                                    Global add-on used when a service has no specific add-on catalog.
                                @endif
                            </div>

                            <form style="margin-top:8px;" method="POST" action="{{ route('admin.add-ons.destroy', array_merge(['addOnService' => $addOn], $addOnFilterParams)) }}" onsubmit="return confirm('Delete this add-on service?');">
                                @csrf
                                @method('DELETE')
                                <button class="btn danger" type="submit">Delete Add-on</button>
                            </form>
                        </div>
                    @empty
                        <div class="mini">No add-on services yet.</div>
                    @endforelse
                </div>

                @if ($addOnServices->total() > 0)
                    <div class="pager">
                        <div class="mini">
                            Showing {{ $addOnServices->count() }} of {{ $addOnServices->total() }} add-on(s)
                        </div>
                        <div style="display: flex; gap: 7px;">
                            @if ($addOnServices->onFirstPage())
                                <span class="mini">Previous</span>
                            @else
                                <a href="{{ $addOnServices->previousPageUrl() }}#add-ons">Previous</a>
                            @endif

                            @if ($addOnServices->hasMorePages())
                                <a href="{{ $addOnServices->nextPageUrl() }}#add-ons">Next</a>
                            @else
                                <span class="mini">Next</span>
                            @endif
                        </div>
                    </div>
                @endif
            </article>
        </section>

        <section id="customers" class="grid">
            <article class="card full">
                <h2 class="title">Customers</h2>
                <p class="sub">Recently active customer accounts with order volume and spending totals.</p>

                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Orders</th>
                            <th>Total Spent</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($customers as $customer)
                            <tr>
                                <td>{{ $customer->name }}</td>
                                <td>{{ $customer->email }}</td>
                                <td>{{ $customer->phone ?: 'N/A' }}</td>
                                <td>{{ (int) $customer->orders_count }}</td>
                                <td>P{{ number_format((float) ($customer->total_spent ?? 0), 2) }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5">No customers found.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </article>
        </section>

        <section id="analytics" class="grid" style="margin-bottom: 18px;">
            <article class="card wide">
                <h2 class="title">Weekly Revenue</h2>
                <p class="sub">{{ $analytics['month_label'] ?? '' }}</p>

                <div class="bars">
                    @foreach ($weeklyRevenue as $index => $amount)
                        @php
                            $height = $maxWeeklyRevenue > 0 ? (int) round(($amount / $maxWeeklyRevenue) * 130) : 6;
                            $height = max($height, 6);
                        @endphp
                        <div class="bar-wrap">
                            <div class="bar-value">P{{ number_format((float) $amount, 0) }}</div>
                            <div class="bar" data-height="{{ $height }}"></div>
                            <div class="bar-label">{{ $chartDays[$index] ?? '' }}</div>
                        </div>
                    @endforeach
                </div>
            </article>

            <article class="card side">
                <h2 class="title">Service Mix</h2>
                <p class="sub">Monthly Revenue: P{{ number_format((float) ($analytics['monthly_revenue'] ?? 0), 2) }}</p>

                <div class="service-breakdown">
                    @forelse (($analytics['service_breakdown'] ?? []) as $item)
                        <div class="item">
                            <span>{{ $item['name'] }}</span>
                            <span>{{ (int) $item['pct'] }}%</span>
                        </div>
                    @empty
                        <div class="mini">No service analytics yet.</div>
                    @endforelse
                </div>
            </article>
        </section>
    </div>
    <script>
        document.querySelectorAll('.bar[data-height]').forEach((barEl) => {
            const height = Number(barEl.getAttribute('data-height')) || 6;
            barEl.style.height = `${height}px`;
        });
    </script>
</body>
</html>
