<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>LaundryHub Admin</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=Work+Sans:wght@400;500;600&display=swap" rel="stylesheet" />
  @php
    $manifestPath = public_path('build/manifest.json');
    $manifest = file_exists($manifestPath) ? json_decode(file_get_contents($manifestPath), true) : [];
    $adminCss = is_array($manifest) ? data_get($manifest, 'resources/css/admin.css.file') : null;
    $adminJs = is_array($manifest) ? data_get($manifest, 'resources/js/admin.js.file') : null;
    $canUseBuildAssets = is_string($adminCss) && is_string($adminJs);

    $adminCssFallback = collect(glob(public_path('build/assets/admin-*.css')) ?: [])
      ->map(fn ($path) => 'build/assets/' . basename($path))
      ->first();
    $adminJsFallback = collect(glob(public_path('build/assets/admin-*.js')) ?: [])
      ->map(fn ($path) => 'build/assets/' . basename($path))
      ->first();
    $canUseBuildFallback = is_string($adminCssFallback) && is_string($adminJsFallback);
  @endphp
  @if ($canUseBuildAssets)
    <link rel="stylesheet" href="{{ asset('build/' . $adminCss) }}">
    <script type="module" src="{{ asset('build/' . $adminJs) }}"></script>
  @elseif ($canUseBuildFallback)
    <link rel="stylesheet" href="{{ asset($adminCssFallback) }}">
    <script type="module" src="{{ asset($adminJsFallback) }}"></script>
  @else
    <link rel="stylesheet" href="{{ asset('assets/admin/admin.css') }}">
    <script defer src="{{ asset('assets/admin/admin.js') }}"></script>
  @endif
  <style>
    html, body {
      margin: 0 !important;
      padding: 0 !important;
    }
  </style>
</head>
<body class="antialiased">
  <div class="bg-aurora"></div>
  <div id="toast" class="toast" role="status" aria-live="polite" aria-atomic="true"></div>

  <div id="login-view" class="relative min-h-screen flex items-center justify-center px-6 py-12">
    <!-- Main Panel -->
    <div class="panel w-full max-w-md p-8 md:px-10 py-10 pb-16 space-y-7 fade-up relative" style="border-radius: var(--r-card);">
      
      <!-- Brand Logo & Header -->
      <div class="flex flex-col items-center text-center space-y-4">
        <div class="login-brand-logo-wrap">
          <img src="{{ asset('images/admin-logo.png') }}" alt="LaundryHub logo" class="login-brand-logo" />
        </div>
        
        <!-- Typography -->
        <div class="space-y-1.5">
          <h1 class="heading-font text-2xl font-bold" style="color: var(--color-text-primary);">Welcome back, Admin</h1>
          <p class="text-[13px] text-muted text-balance max-w-xs mx-auto leading-relaxed">
            Sign in to access your admin dashboard and manage laundry operations.
          </p>
        </div>
      </div>

      <!-- Auth Form -->
      <form id="login-form" class="space-y-4">
        <!-- Email Input -->
        <div class="space-y-1.5">
          <label class="text-[11px] font-semibold text-muted tracking-wide uppercase">Email address</label>
          <input id="login-email" type="email" class="input-shell w-full" placeholder="admin@laundryhub.com" required />
        </div>
        
        <!-- Password Input -->
        <div class="space-y-1.5">
          <label class="text-[11px] font-semibold text-muted tracking-wide uppercase">Password</label>
          <div class="relative">
            <input id="login-password" type="password" class="input-shell w-full pr-10" placeholder="Enter password" required />
            <button type="button" id="toggle-password" class="eye-toggle" aria-label="Toggle password visibility">
              <!-- Closed Eye (Default) -->
              <svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                <line x1="1" y1="1" x2="23" y2="23"></line>
              </svg>
            </button>
          </div>
          <div class="flex justify-start pt-1">
            <a href="#" class="text-[11px] font-semibold hover:underline transition-colors" style="color: var(--color-primary);">Forgot password?</a>
          </div>
        </div>
        
        <!-- Submit Button -->
        <button id="login-submit" type="submit" class="button-primary w-full button-with-spinner mt-2" aria-busy="false" style="padding: 10px; font-size: 13px;">
          <span class="btn-label">Sign in to dashboard</span>
          <span class="btn-spinner hidden" aria-hidden="true"></span>
        </button>
        <div id="login-error" class="hidden text-[12px] font-medium text-red-600 mt-2 text-center"></div>
      </form>

      <!-- Warning Notice Pill -->
      <div class="flex items-center justify-center gap-2 py-2 px-4 mx-auto w-max rounded-full" style="background: var(--badge-amber-bg); color: var(--badge-amber-text);">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px;">
          <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
          <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
        </svg>
        <span class="text-[11px] font-medium tracking-tight">This portal is for authorized administrators only.</span>
      </div>

      <!-- Login Page Footer Inside Panel -->
      <div class="absolute bottom-4 left-0 w-full text-center">
        <p class="text-[10px] text-muted font-medium tracking-wide">
          &copy; 2026 LaundryHub. All rights reserved.
        </p>
      </div>
    </div>
  </div>

  <div id="app-view" class="hidden relative min-h-screen">
    <header class="mobile-topbar">
      <button id="sidebar-toggle" class="mobile-menu-button" type="button" aria-label="Open navigation menu" aria-expanded="false">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
      </button>
      <div class="mobile-topbar-brand">
        <div class="brand-mark brand-mark-logo" aria-hidden="true">
          <img src="{{ asset('images/admin-logo.png') }}" alt="LaundryHub logo" class="brand-logo-image" />
        </div>
        <div>
          <p class="sidebar-title">LaundryHub</p>
        </div>
      </div>
    </header>

    <div class="page">
      <aside class="sidebar">
        <div class="sidebar-surface">
          <div class="sidebar-header">
            <div class="sidebar-brand">
              <div class="sidebar-brand-copy">
                <p class="sidebar-eyebrow">Admin Management</p>
              </div>
              <div class="brand-mark brand-mark-logo" aria-hidden="true">
                <img src="{{ asset('images/admin-logo.png') }}" alt="LaundryHub logo" class="brand-logo-image" />
              </div>
            </div>
            <p class="sidebar-caption">A laundry service platform built for fast, reliable, and hassle-free cleaning.</p>
          </div>

          <nav class="nav-list">
            <button class="nav-link active" data-view="dashboard" type="button">
              <span class="nav-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
              </span>
              <span>Dashboard</span>
            </button>
            <button class="nav-link" data-view="bookings" type="button">
              <span class="nav-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2"/><rect x="9" y="3" width="6" height="4" rx="1"/><path d="M9 12h6M9 16h4"/></svg>
              </span>
              <span>Bookings</span>
            </button>
            <button class="nav-link" data-view="customers" type="button">
              <span class="nav-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>
              </span>
              <span>Customers</span>
            </button>
            <button class="nav-link" data-view="analytics" type="button">
              <span class="nav-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
              </span>
              <span>Analytics and Reports</span>
            </button>
            <button class="nav-link" data-view="services" type="button">
              <span class="nav-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93A10 10 0 1 0 4.93 19.07"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2"/></svg>
              </span>
              <span>Services</span>
            </button>
          </nav>

          <div class="sidebar-footer">
            <button id="logout-button" class="button-outline w-full" type="button" style="display:flex;align-items:center;justify-content:center;gap:8px">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>
              <span>Logout</span>
            </button>
          </div>
        </div>
      </aside>

      <main class="space-y-8">
        <div class="main-toolbar">
          <div class="admin-profile-chip">
            <div id="header-admin-avatar" class="admin-profile-avatar">A</div>
            <div class="admin-profile-copy">
              <p id="header-admin-name" class="admin-profile-name">LaundryHub Admin</p>
              <p class="admin-profile-role">ADMINISTRATOR</p>
            </div>
          </div>
        </div>

        <section class="view-section space-y-6" data-view="dashboard">
          <header class="flex flex-col gap-3">
            <div>
              <h1 id="header-title" class="heading-font text-3xl font-semibold">Dashboard</h1>
              <p class="text-sm text-muted">Keep a close eye on laundry operations today.</p>
            </div>
          </header>

          <div class="stats-grid">
            <div class="panel stat-card fade-up">
              <p class="card-label">Total bookings</p>
              <div id="stat-total-bookings" class="card-value heading-font">--</div>
              <div id="stat-badge-total" class="stat-badge muted">Loading…</div>
            </div>
            <div class="panel stat-card fade-up delay-1">
              <p class="card-label">Pending orders</p>
              <div id="stat-pending" class="card-value heading-font">--</div>
              <div id="stat-badge-pending" class="stat-badge muted">Loading…</div>
            </div>
            <div class="panel stat-card fade-up delay-2">
              <p class="card-label">Revenue today</p>
              <div id="stat-revenue" class="card-value heading-font">--</div>
              <div id="stat-badge-revenue" class="stat-badge muted">Loading…</div>
            </div>
            <div class="panel stat-card fade-up delay-3">
              <p class="card-label">Active customers</p>
              <div id="stat-customers" class="card-value heading-font">--</div>
              <div id="stat-badge-customers" class="stat-badge muted">Loading…</div>
            </div>
          </div>

          <div class="grid gap-6 lg:grid-cols-[1.5fr_1fr]">
            <div class="panel p-6 space-y-4">
              <div class="flex items-center justify-between">
                <h3 class="heading-font text-lg font-semibold">Recent orders</h3>
                <div class="recent-orders-meta">
                  <span class="text-xs text-muted">Last 5 bookings</span>
                  <button id="recent-orders-view-all" class="recent-orders-link" type="button">View all bookings</button>
                </div>
              </div>
              <div class="table-shell">
                <table id="recent-orders-table">
                  <colgroup>
                  </colgroup>
                  <thead>
                    <tr>
                      <th>Order</th>
                      <th>Customer</th>
                      <th>Service</th>
                      <th>Total</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody id="recent-orders-body"></tbody>
                </table>
              </div>
            </div>

            <div class="panel p-6 space-y-4">
              <div class="flex items-center justify-between">
                <h3 class="heading-font text-lg font-semibold">Top customers</h3>
                <span class="text-xs text-muted">Highest lifetime spend</span>
              </div>
              <div id="top-customers-body" class="space-y-2"></div>
            </div>
          </div>
        </section>

        <section class="view-section hidden space-y-6" data-view="bookings">
          <header class="flex flex-col gap-3">
            <div>
              <h1 class="heading-font text-3xl font-semibold">Bookings</h1>
              <p class="text-sm text-muted">Manage and track all laundry orders.</p>
            </div>
          </header>

          <header class="bookings-header">
            <div class="bookings-actions">
              <div class="search-shell">
                <svg class="text-muted" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                <input type="text" placeholder="Search orders..." class="search-input" />
              </div>
              <button class="button-outline button-icon" type="button">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
                Filter
              </button>
              <button class="button-primary" type="button">
                Add order
              </button>
            </div>
          </header>

          <div class="bookings-kpis">
            <div class="panel bookings-kpi-card">
              <p class="text-[10px] uppercase font-medium text-muted tracking-[0.07em]">Total orders</p>
              <div class="text-[20px] font-medium mt-1 leading-tight text-[var(--color-text-primary)]" data-status-count="all">0</div>
              <div class="stat-badge blue mt-2">All time</div>
            </div>
            <div class="panel bookings-kpi-card">
              <p class="text-[10px] uppercase font-medium text-muted tracking-[0.07em]">Pending</p>
              <div class="text-[20px] font-medium mt-1 leading-tight text-[var(--color-text-primary)]" data-status-count="pending">0</div>
              <div class="stat-badge amber mt-2">Needs action</div>
            </div>
            <div class="panel bookings-kpi-card">
              <p class="text-[10px] uppercase font-medium text-muted tracking-[0.07em]">Completed</p>
              <div class="text-[20px] font-medium mt-1 leading-tight text-[var(--color-text-primary)]" data-status-count="completed">0</div>
              <div class="stat-badge green mt-2">Good standing</div>
            </div>
            <div class="panel bookings-kpi-card">
              <p class="text-[10px] uppercase font-medium text-muted tracking-[0.07em]">Cancelled</p>
              <div class="text-[20px] font-medium mt-1 leading-tight text-[var(--color-text-primary)]" data-status-count="cancelled">0</div>
              <div class="stat-badge red mt-2">Review needed</div>
            </div>
          </div>

          <div class="panel bg-white mt-6" style="border: 0.5px solid var(--color-border); border-radius: 12px; display: flex; flex-direction: column;">
            <div class="flex items-center justify-between" style="padding: 16px 18px 12px; border-bottom: 0.5px solid var(--color-border);">
              <h2 class="text-[14px] font-medium text-[var(--color-text-primary)]">All bookings</h2>
              <div id="booking-status-chips" class="flex gap-2">
                <button class="bookings-tab active" data-status="all">All</button>
                <button class="bookings-tab" data-status="pending">Pending</button>
                <button class="bookings-tab" data-status="ongoing">Ongoing</button>
                <button class="bookings-tab" data-status="completed">Completed</button>
              </div>
            </div>

            <div class="table-shell" style="border: none; border-radius: 0;">
              <table id="bookings-table">
                <colgroup>
                  <col style="width: 80px;" />
                  <col style="width: 130px;" />
                  <col />
                  <col style="width: 60px;" />
                  <col style="width: 75px;" />
                  <col style="width: 105px;" />
                  <col style="width: 90px;" />
                  <col style="width: 70px;" />
                </colgroup>
                <thead>
                  <tr>
                    <th>Order</th>
                    <th>Customer</th>
                    <th>Service</th>
                    <th>Weight</th>
                    <th>Total</th>
                    <th>Status</th>
                    <th>Created</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody id="bookings-table-body"></tbody>
              </table>
            </div>

            <div class="flex items-center justify-between mt-auto" style="padding: 16px 18px; border-top: 0.5px solid var(--color-border);">
              <div id="bookings-footer-info" class="text-[11px] text-muted">Showing 0 of 0 orders — Page 1 of 1</div>
              <div class="flex items-center gap-2">
                <button id="bookings-prev" class="bookings-page-btn outline">Previous</button>
                <div id="bookings-current-page" class="bookings-page-btn active">1</div>
                <button id="bookings-next" class="bookings-page-btn outline">Next</button>
              </div>
            </div>
          </div>
        </section>

        <section class="view-section hidden space-y-6" data-view="customers">
          <header class="flex flex-col gap-3">
            <div>
              <h1 class="heading-font text-3xl font-semibold">Customers</h1>
              <p class="text-sm text-muted">View customer profiles, activity, and account status.</p>
            </div>
          </header>

          <div class="panel p-5 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <div class="flex-row" style="width:100%;">
              <input id="customers-search-input" class="input-shell" placeholder="Search name, email, phone" />
              <button id="customers-search-button" class="button-primary" type="button">Search</button>
            </div>
            <div class="text-xs text-muted">Click a customer to view profile details.</div>
          </div>

          <div class="panel p-6 space-y-4">
            <div class="table-shell">
              <table>
                <thead>
                  <tr>
                    <th>Customer</th>
                    <th>Phone</th>
                    <th>Orders</th>
                    <th>Total spent</th>
                    <th>Points</th>
                    <th></th>
                  </tr>
                </thead>
                <tbody id="customers-table-body"></tbody>
              </table>
            </div>
            <div class="flex items-center justify-between">
              <button id="customers-prev" class="button-outline" type="button">Previous</button>
              <span id="customers-page-info" class="text-xs text-muted">Page 1</span>
              <button id="customers-next" class="button-outline" type="button">Next</button>
            </div>
          </div>
        </section>

        <section class="view-section hidden space-y-6" data-view="analytics">
          <header class="flex flex-col gap-3">
            <div>
              <h1 class="heading-font text-3xl font-semibold">Analytics and Reports</h1>
              <p class="text-sm text-muted">Track revenue trends, service mix, and performance insights.</p>
            </div>
          </header>

          <div class="grid gap-6 lg:grid-cols-[1.1fr_0.9fr]">
            <div class="panel p-6 space-y-4">
              <div class="flex items-center justify-between">
                <div>
                  <h3 class="heading-font text-lg font-semibold">Weekly revenue</h3>
                  <p class="text-xs text-muted" id="analytics-month"></p>
                </div>
                <div class="text-sm font-semibold" id="analytics-monthly-revenue">--</div>
              </div>
              <div class="h-48 flex items-end justify-between gap-4" id="weekly-bars"></div>
            </div>

            <div class="panel p-6 space-y-4">
              <h3 class="heading-font text-lg font-semibold">Service breakdown</h3>
              <div id="service-breakdown-body" class="space-y-4"></div>
            </div>
          </div>

          <div class="grid gap-6 lg:grid-cols-2">
            <div class="panel p-6 space-y-2">
              <div class="text-xs text-muted">Monthly revenue</div>
              <div id="analytics-monthly-card" class="heading-font text-2xl font-semibold">--</div>
            </div>
            <div class="panel p-6 space-y-2">
              <div class="text-xs text-muted">Avg rating</div>
              <div id="analytics-avg-rating" class="heading-font text-2xl font-semibold">N/A</div>
            </div>
          </div>
        </section>

        <section class="view-section hidden space-y-6" data-view="services">
          <header class="flex flex-col gap-3">
            <div>
              <h1 class="heading-font text-3xl font-semibold">Services</h1>
              <p class="text-sm text-muted">Create, update, and manage laundry service offerings.</p>
            </div>
          </header>

          <div class="grid gap-6 lg:grid-cols-[1.2fr_0.8fr]">
            <div class="panel p-6 space-y-4">
              <div class="table-shell">
                <table>
                  <thead>
                    <tr>
                      <th>Service</th>
                      <th>Price per kg</th>
                      <th>Category</th>
                      <th>Status</th>
                      <th></th>
                    </tr>
                  </thead>
                  <tbody id="services-table-body"></tbody>
                </table>
              </div>
            </div>

              <div class="space-y-6">
                <div class="panel p-6 space-y-4">
                  <h3 id="service-form-title" class="heading-font text-lg font-semibold">Create service</h3>
                  <div class="space-y-3">
                    <input id="service-name" class="input-shell" placeholder="Service name" />
                    <textarea id="service-description" class="input-shell" rows="3" placeholder="Description"></textarea>
                    <input id="service-price" class="input-shell" type="number" min="0" step="0.01" placeholder="Price per kg" />
                    <input id="service-category" class="input-shell" placeholder="Category" />
                    <input id="service-image" class="input-shell" placeholder="Image URL" />
                    <label class="flex items-center gap-2 text-sm text-muted">
                      <input id="service-active" type="checkbox" checked />
                      Active
                    </label>
                  </div>
                  <div class="flex items-center gap-3">
                    <button id="service-save" class="button-primary" type="button">Save</button>
                    <button id="service-clear" class="button-outline" type="button">Clear</button>
                  </div>
                </div>

                <div class="panel p-6 space-y-4">
                  <div class="flex items-center justify-between">
                    <h3 class="heading-font text-lg font-semibold">Top customers</h3>
                    <span class="text-xs text-muted">Highest lifetime spend</span>
                  </div>
                  <div id="services-top-customers-body" class="space-y-2"></div>
                </div>
              </div>
          </div>
        </section>
      </main>
    </div>
  </div>

  <div id="sidebar-overlay" class="overlay"></div>
  <div id="drawer-overlay" class="overlay"></div>

  <div id="booking-modal-overlay" class="overlay"></div>
  <div id="booking-modal" class="modal hidden" role="dialog" aria-modal="true" aria-labelledby="booking-modal-title">
    <div class="modal-panel">
      <div class="modal-header">
        <div class="space-y-1">
          <h3 id="booking-modal-title" class="heading-font text-lg font-semibold">Booking details</h3>
          <p id="booking-modal-subtitle" class="text-xs text-muted"></p>
        </div>
        <button id="booking-modal-close" class="modal-close button-outline" type="button" aria-label="Close booking details">
          <span aria-hidden="true">✕</span>
        </button>
      </div>
      <div id="booking-modal-body" class="modal-body"></div>
    </div>
  </div>

  <div id="customer-drawer" class="drawer">
    <div class="p-6 space-y-4 h-full overflow-y-auto">
      <div class="flex items-center justify-between">
        <h3 id="customer-drawer-title" class="heading-font text-lg font-semibold">Customer</h3>
        <button id="customer-drawer-close" class="button-outline" type="button">Close</button>
      </div>

      <div class="grid gap-3">
        <label class="text-xs text-muted">Name</label>
        <input id="customer-name" class="input-shell" />
        <label class="text-xs text-muted">Email</label>
        <input id="customer-email" class="input-shell" readonly />
        <label class="text-xs text-muted">Phone</label>
        <input id="customer-phone" class="input-shell" />
        <label class="text-xs text-muted">Address</label>
        <input id="customer-address" class="input-shell" />
        <label class="text-xs text-muted">City</label>
        <input id="customer-city" class="input-shell" />
        <label class="text-xs text-muted">ZIP</label>
        <input id="customer-zip" class="input-shell" />
        <label class="text-xs text-muted">Country</label>
        <input id="customer-country" class="input-shell" />
        <label class="flex items-center gap-2 text-sm text-muted">
          <input id="customer-notifications" type="checkbox" />
          Notifications enabled
        </label>
      </div>

      <div class="panel p-4 space-y-3">
        <div class="text-xs text-muted">Profile details</div>
        <div class="details-grid">
          <div>
            <div class="details-label">Date of birth</div>
            <div id="customer-dob" class="details-value">--</div>
          </div>
          <div>
            <div class="details-label">Gender</div>
            <div id="customer-gender" class="details-value">--</div>
          </div>
          <div>
            <div class="details-label">Preferred language</div>
            <div id="customer-language" class="details-value">--</div>
          </div>
          <div>
            <div class="details-label">Email verified</div>
            <div id="customer-email-verified" class="details-value">--</div>
          </div>
          <div>
            <div class="details-label">Profile completed</div>
            <div id="customer-profile-completed" class="details-value">--</div>
          </div>
          <div>
            <div class="details-label">Member since</div>
            <div id="customer-member-since" class="details-value">--</div>
          </div>
          <div>
            <div class="details-label">Last login</div>
            <div id="customer-last-login" class="details-value">--</div>
          </div>
          <div>
            <div class="details-label">Bio</div>
            <div id="customer-bio" class="details-value">--</div>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-3 gap-3 text-sm">
        <div class="panel p-3 text-center">
          <div class="text-xs text-muted">Points</div>
          <div id="customer-loyalty" class="font-semibold">0</div>
        </div>
        <div class="panel p-3 text-center">
          <div class="text-xs text-muted">Orders</div>
          <div id="customer-orders-count" class="font-semibold">0</div>
        </div>
        <div class="panel p-3 text-center">
          <div class="text-xs text-muted">Total</div>
          <div id="customer-total-spent" class="font-semibold">0</div>
        </div>
      </div>

      <div class="space-y-3">
        <h4 class="heading-font font-semibold">
          Order history <span id="customer-orders-title-count" class="text-xs text-muted"></span>
        </h4>
        <div class="table-shell">
          <table>
            <thead>
              <tr>
                <th>Order</th>
                <th>Service</th>
                <th>Weight</th>
                <th>Total</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody id="customer-orders-body"></tbody>
          </table>
        </div>
        <div class="flex items-center justify-between">
          <span id="customer-orders-page-info" class="text-xs text-muted">Page 1</span>
          <button id="customer-orders-load" class="button-outline" type="button">Load more</button>
        </div>
      </div>

      <button id="customer-save" class="button-primary w-full" type="button">Save changes</button>
    </div>
  </div>
</body>
</html>
