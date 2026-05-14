import './bootstrap';

const state = {
  token: null,
  user: null,
  isLoginSubmitting: false,
  isLogoutSubmitting: false,
  view: 'dashboard',
  bookings: {
    page: 1,
    perPage: 20,
    status: 'all',
    steps: {},
    byId: {},
    activeOrderId: null,
  },
  customers: {
    page: 1,
    perPage: 20,
    search: '',
  },
  services: {
    editingId: null,
  },
  customerOrders: {
    page: 1,
    perPage: 10,
    lastPage: 1,
  },
  currentCustomerId: null,
};

const viewTitles = {
  dashboard: 'Dashboard',
  bookings: 'Bookings',
  customers: 'Customers',
  analytics: 'Analytics and Reports',
  services: 'Services',
};

const qs = (selector, root = document) => root.querySelector(selector);
const qsa = (selector, root = document) => Array.from(root.querySelectorAll(selector));
const apiBaseUrl = `${window.LAUNDRYHUB_API_BASE_URL || '/api'}`.replace(/\/$/, '');

function setText(target, value) {
  const el = typeof target === 'string' ? qs(target) : target;
  if (el) el.textContent = value;
}

function show(el) {
  if (el) el.classList.remove('hidden');
}

function hide(el) {
  if (el) el.classList.add('hidden');
}

function showToast(message) {
  const toast = qs('#toast');
  if (!toast) return;
  toast.textContent = message;
  toast.classList.add('show');
  toast.setAttribute('aria-hidden', 'false');
  setTimeout(() => {
    toast.classList.remove('show');
    toast.setAttribute('aria-hidden', 'true');
  }, 3000);
}

function formatCurrency(value) {
  const num = Number(value || 0);
  return `PHP ${num.toLocaleString('en-PH', { maximumFractionDigits: 0 })}`;
}

function formatDate(value) {
  if (!value) return '---';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleDateString('en-PH', { month: 'short', day: 'numeric', year: 'numeric' });
}

function formatValue(value, fallback = '---') {
  if (value === null || value === undefined || value === '') return fallback;
  return value;
}

function escapeHtml(value) {
  return `${value ?? ''}`
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

function formatYesNo(value) {
  return value ? 'Yes' : 'No';
}

function normalizeRole(value) {
  return `${value || ''}`.trim().toLowerCase();
}

function normalizeStatus(value) {
  return (value || '').toString().toLowerCase();
}

function formatDeliveryType(value) {
  const type = normalizeStatus(value) || 'pickup';
  return type === 'delivery' ? 'Delivery' : 'Pickup';
}

function formatOrderDisplayId(order) {
  const rawId = order?.id ?? order?.order_id ?? '';
  const idStr = String(rawId).replace(new RegExp('^#?LH-+'), '');
  if (!idStr) return String(rawId || '---');
  return `#LH-${idStr.padStart(3, '0')}`;
}

function renderBookingDetailsContent(order) {
  const orderId = order.order_id || order.id;
  const statusValue = normalizeStatus(order.status);
  const currentStep = getStepForOrder(orderId, statusValue);
  const pickupDate = formatDate(order.pickup_date);
  const deliveryDate = formatDate(order.delivery_date || order.pickup_date);
  const deliveryType = formatDeliveryType(order.delivery_type);
  const pickupAddress = formatValue(order.pickup_address);
  const updatedAt = formatDate(order.updated_at);
  const stepChips = ['ongoing', 'ready', 'completed'].includes(statusValue)
    ? renderStepChips(orderId, currentStep)
    : '';
  const actions = renderBookingActions(orderId, statusValue);

  return `
    <div class="details-grid">
      <div>
        <div class="details-label">Pickup date</div>
        <div class="details-value">${pickupDate}</div>
      </div>
      <div>
        <div class="details-label">Delivery date</div>
        <div class="details-value">${deliveryDate}</div>
      </div>
      <div>
        <div class="details-label">Delivery type</div>
        <div class="details-value">${deliveryType}</div>
      </div>
      <div>
        <div class="details-label">Pickup address</div>
        <div class="details-value">${pickupAddress}</div>
      </div>
      <div>
        <div class="details-label">Created</div>
        <div class="details-value">${formatDate(order.created_at)}</div>
      </div>
      <div>
        <div class="details-label">Updated</div>
        <div class="details-value">${updatedAt}</div>
      </div>
    </div>
    <div class="details-actions">
      ${stepChips ? `<div class="step-chips">${stepChips}</div>` : '<div></div>'}
      <div class="action-buttons">${actions || '<span class="text-xs text-muted">No actions</span>'}</div>
    </div>
  `;
}

function statusToStep(status) {
  if (status === 'ready') return 2;
  if (status === 'completed') return 3;
  if (status === 'ongoing') return 0;
  return null;
}

function stepToStatus(step) {
  if (step === 2) return 'ready';
  if (step === 3) return 'completed';
  return 'ongoing';
}

function setActiveView(view) {
  state.view = view;

  qsa('.view-section').forEach((section) => {
    section.classList.toggle('hidden', section.dataset.view !== view);
  });

  qsa('[data-view]').forEach((link) => {
    link.classList.toggle('active', link.dataset.view === view);
  });

  loadView(view).catch((error) => {
    console.error('Failed to load view', error);
  });
}

function setSession(token, user) {
  localStorage.setItem('lh_admin_token', token);
  localStorage.setItem('lh_admin_user', JSON.stringify(user));
  state.token = token;
  state.user = user;
}

function clearSession() {
  localStorage.removeItem('lh_admin_token');
  localStorage.removeItem('lh_admin_user');
  state.token = null;
  state.user = null;
}

function isLoginPagePath() {
  return window.location.pathname === '/admin';
}

function isDashboardPagePath() {
  return window.location.pathname.startsWith('/admin/dashboard');
}

function showLogin() {
  closeBookingModal();
  if (!isLoginPagePath()) {
    window.location.assign('/admin');
    return;
  }
  show(qs('.bg-aurora'));
  show(qs('#login-view'));
  hide(qs('#app-view'));
}

function showApp() {
  if (!isDashboardPagePath()) {
    window.location.assign('/admin/dashboard');
    return;
  }
  hide(qs('.bg-aurora'));
  hide(qs('#login-view'));
  show(qs('#app-view'));
  removeDecorativeMainWatermarks();
  if (state.user) {
    const fullAdminName = state.user.name?.trim() || 'LaundryHub Admin';
    const adminName = 'Admin';
    const adminInitial = adminName.charAt(0).toUpperCase() || 'A';
    const adminEmail = state.user.email || 'admin@laundryhub.com';
    setText('#user-name', fullAdminName || 'Admin');
    setText('#user-email', state.user.email || '');
    setText('#header-admin-name', adminName);
    setText('#header-admin-avatar', adminInitial);
    setText('#sidebar-admin-name', adminName);
    setText('#sidebar-admin-email', adminEmail);
    setText('#sidebar-admin-avatar', adminInitial);
  }
}

function removeDecorativeMainWatermarks() {
  const appView = qs('#app-view');
  if (!appView || appView.classList.contains('hidden')) return;

  const keepZones = ['.sidebar', '.mobile-topbar', '#login-view', '.drawer', '.modal'];
  const candidates = qsa('body *');

  candidates.forEach((el) => {
    if (!(el instanceof HTMLElement)) return;
    if (el.id === 'app-view' || el.id === 'login-view') return;
    if (keepZones.some((selector) => el.closest(selector))) return;

    const rect = el.getBoundingClientRect();
    if (rect.width < 320 || rect.height < 320) return;

    const style = window.getComputedStyle(el);
    const isOverlayLike = ['fixed', 'absolute'].includes(style.position)
      || style.pointerEvents === 'none'
      || Number(style.opacity || '1') < 0.35;
    if (!isOverlayLike) return;

    const classText = `${el.className || ''}`.toLowerCase();
    const idText = `${el.id || ''}`.toLowerCase();
    const looksDecorative = classText.includes('watermark')
      || classText.includes('logo')
      || classText.includes('aurora')
      || classText.includes('bg-')
      || idText.includes('watermark')
      || idText.includes('logo');

    if (looksDecorative || (style.zIndex === '0' && style.pointerEvents === 'none')) {
      el.style.display = 'none';
    }
  });
}

function closeSidebar() {
  qs('.sidebar')?.classList.remove('open');
  qs('#sidebar-overlay')?.classList.remove('show');
  qs('#sidebar-toggle')?.setAttribute('aria-expanded', 'false');
}

function toggleSidebar() {
  const sidebar = qs('.sidebar');
  const overlay = qs('#sidebar-overlay');
  const toggle = qs('#sidebar-toggle');
  if (!sidebar || !overlay || !toggle) return;

  const isOpen = sidebar.classList.toggle('open');
  overlay.classList.toggle('show', isOpen);
  toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
}

function setLoginLoading(isLoading) {
  const submit = qs('#login-submit');
  const spinner = qs('#login-submit .btn-spinner');
  const label = qs('#login-submit .btn-label');
  const email = qs('#login-email');
  const password = qs('#login-password');

  if (submit) {
    submit.disabled = isLoading;
    submit.classList.toggle('is-loading', isLoading);
    submit.setAttribute('aria-busy', isLoading ? 'true' : 'false');
  }

  if (spinner) spinner.classList.toggle('hidden', !isLoading);
  if (label) label.textContent = isLoading ? 'Signing in...' : 'Sign in';

  if (email) email.disabled = isLoading;
  if (password) password.disabled = isLoading;
}

function setLogoutLoading(isLoading) {
  const confirm = qs('#logout-modal-confirm');
  const spinner = qs('#logout-modal-confirm .btn-spinner');
  const label = qs('#logout-modal-confirm .btn-label');
  const cancel = qs('#logout-modal-cancel');

  if (confirm) {
    confirm.disabled = isLoading;
    confirm.classList.toggle('is-loading', isLoading);
    confirm.setAttribute('aria-busy', isLoading ? 'true' : 'false');
  }

  if (spinner) spinner.classList.toggle('hidden', !isLoading);
  if (label) label.textContent = isLoading ? 'Logging out...' : 'Yes';
  if (cancel) cancel.disabled = isLoading;
}

async function apiRequest(path, options = {}) {
  const controller = new AbortController();
  const timeoutMs = Number.isFinite(options.timeoutMs) ? options.timeoutMs : 20000;
  const timeoutId = timeoutMs > 0
    ? setTimeout(() => controller.abort(), timeoutMs)
    : null;

  const config = {
    method: options.method || 'GET',
    headers: {
      Accept: 'application/json',
      ...options.headers,
    },
    signal: controller.signal,
  };

  if (!options.skipAuth && state.token) {
    config.headers.Authorization = `Bearer ${state.token}`;
  }

  if (options.body) {
    config.headers['Content-Type'] = 'application/json';
    config.body = JSON.stringify(options.body);
  }

  try {
    const response = await fetch(`${apiBaseUrl}${path}`, config);
    if (timeoutId) clearTimeout(timeoutId);
    let data = null;
    try {
      data = await response.json();
    } catch (_) {
      data = null;
    }

    if (response.status === 401 || response.status === 403) {
      clearSession();
      showLogin();
      showToast('Session expired. Please sign in again.');
    }

    return { ok: response.ok, status: response.status, data };
  } catch (error) {
    if (timeoutId) clearTimeout(timeoutId);
    if (error?.name === 'AbortError') {
      showToast('Request timed out. The server may still be starting up.');
      return { ok: false, status: 408, data: { message: 'Request timed out.' } };
    }
    showToast('Network error. Please try again.');
    return { ok: false, status: 0, data: null };
  }
}

async function bootstrapApp() {
  const onLoginPage = isLoginPagePath();
  const token = localStorage.getItem('lh_admin_token');
  const rawUser = localStorage.getItem('lh_admin_user');

  if (!token || !rawUser) {
    clearSession();
    showLogin();
    return;
  }

  let user = null;
  try {
    user = JSON.parse(rawUser);
  } catch (_) {
    clearSession();
    showLogin();
    return;
  }

  if (!user || normalizeRole(user.role) !== 'admin') {
    clearSession();
    showLogin();
    return;
  }

  if (onLoginPage) {
    window.location.assign('/admin/dashboard');
    return;
  }

  state.token = token;
  state.user = user;
  showApp();
  setActiveView('dashboard');

  const meRes = await apiRequest('/user');
  if (meRes.ok && normalizeRole(meRes.data?.role) === 'admin') {
    setSession(token, meRes.data);
  }
}

async function handleLogin(event) {
  event.preventDefault();
  if (state.isLoginSubmitting) return;

  const email = qs('#login-email')?.value.trim() || '';
  const password = qs('#login-password')?.value || '';
  const errorBox = qs('#login-error');
  hide(errorBox);

  state.isLoginSubmitting = true;
  setLoginLoading(true);
  let shouldRedirect = false;
  let res;
  try {
    res = await apiRequest('/login', {
      method: 'POST',
      body: { email, password },
      skipAuth: true,
      timeoutMs: 45000,
    });
    if (!res.ok) {
      setText(errorBox, res.data?.message || 'Login failed.');
      show(errorBox);
      return;
    }

    const user = res.data?.user || res.data?.data?.user || null;
    const token = `${
      res.data?.token ||
      res.data?.access_token ||
      res.data?.data?.token ||
      res.data?.data?.access_token ||
      ''
    }`.trim();
    const role = normalizeRole(user?.role);

    if (!token) {
      setText(errorBox, 'Login failed. Missing access token.');
      show(errorBox);
      return;
    }

    if (role !== 'admin') {
      setText(errorBox, 'This account does not have admin access.');
      show(errorBox);
      return;
    }

    setSession(token, user);
    shouldRedirect = true;
    window.location.assign('/admin/dashboard');
  } finally {
    state.isLoginSubmitting = false;
    if (!shouldRedirect) {
      setLoginLoading(false);
    }
  }
}

async function handleLogout() {
  openLogoutModal();
}

function openLogoutModal() {
  if (state.isLogoutSubmitting) return;
  setLogoutLoading(false);
  qs('#logout-modal-overlay')?.classList.add('show');
  qs('#logout-modal')?.classList.remove('hidden');
  qs('#logout-modal')?.classList.add('show');
}

function closeLogoutModal() {
  if (state.isLogoutSubmitting) return;
  setLogoutLoading(false);
  qs('#logout-modal-overlay')?.classList.remove('show');
  qs('#logout-modal')?.classList.remove('show');
  qs('#logout-modal')?.classList.add('hidden');
}

async function confirmLogout() {
  if (state.isLogoutSubmitting) return;
  state.isLogoutSubmitting = true;
  setLogoutLoading(true);

  try {
    if (state.token) {
      await apiRequest('/logout', { method: 'POST' });
    }
  } catch (error) {
    // Proceed with local logout even if the API request fails.
  } finally {
    clearSession();
    window.location.assign('/admin');
  }
}

async function loadView(view) {
  if (view === 'dashboard') {
    await loadDashboard();
  } else if (view === 'bookings') {
    await loadBookings();
  } else if (view === 'customers') {
    await loadCustomers();
  } else if (view === 'analytics') {
    await loadAnalytics();
  } else if (view === 'services') {
    await loadServices();
  }
}

async function loadDashboard() {
  setText('#stat-total-bookings', '--');
  setText('#stat-pending', '--');
  setText('#stat-revenue', '--');
  setText('#stat-customers', '--');

  const [statsRes, recentRes, topRes] = await Promise.all([
    apiRequest('/admin/stats'),
    apiRequest('/admin/orders/recent'),
    apiRequest('/admin/top-customers'),
  ]);

  if (statsRes.ok && statsRes.data) {
    const total = statsRes.data.total_bookings ?? 0;
    const pending = statsRes.data.pending_count ?? 0;
    const revenue = statsRes.data.revenue_today ?? 0;
    const customers = statsRes.data.customer_count ?? 0;

    setText('#stat-total-bookings', total);
    setText('#stat-pending', pending);
    setText('#stat-revenue', formatCurrency(revenue));
    setText('#stat-customers', customers);

    // Stat badges
    const badgeTotal = qs('#stat-badge-total');
    if (badgeTotal) {
      badgeTotal.className = 'stat-badge green';
      badgeTotal.textContent = 'All time';
    }
    const badgePending = qs('#stat-badge-pending');
    if (badgePending) {
      if (pending > 0) {
        badgePending.className = 'stat-badge amber';
        badgePending.textContent = 'Needs action';
      } else {
        badgePending.className = 'stat-badge green';
        badgePending.textContent = 'All clear';
      }
    }
    const badgeRevenue = qs('#stat-badge-revenue');
    if (badgeRevenue) {
      if (revenue > 0) {
        badgeRevenue.className = 'stat-badge green';
        badgeRevenue.textContent = 'Earning today';
      } else {
        badgeRevenue.className = 'stat-badge red';
        badgeRevenue.textContent = 'No revenue yet';
      }
    }
    const badgeCustomers = qs('#stat-badge-customers');
    if (badgeCustomers) {
      badgeCustomers.className = 'stat-badge green';
      badgeCustomers.textContent = 'Growing';
    }
  }

  renderRecentOrders(recentRes.ok ? recentRes.data?.data || [] : []);
  renderTopCustomersTo(topRes.ok ? topRes.data?.data || [] : [], '#top-customers-body');
}

function renderRecentOrders(orders) {
  const body = qs('#recent-orders-body');
  if (!body) return;
  body.innerHTML = '';

  if (!orders.length) {
    body.innerHTML = '<tr><td colspan="5">No recent orders.</td></tr>';
    return;
  }

  orders.forEach((order) => {
    const tr = document.createElement('tr');
    const statusValue = (order.status || '').toString().toLowerCase();
    tr.innerHTML = `
      <td><span class="order-id">${order.id || ''}</span></td>
      <td>${order.customer_name || 'Unknown'}</td>
      <td>${order.service_type || 'Service'}</td>
      <td>${formatCurrency(order.total_price || 0)}</td>
      <td><span class="status-pill" data-status="${statusValue}">${order.status || 'Pending'}</span></td>
    `;
    body.appendChild(tr);
  });
}

function renderTopCustomers(customers) {
  renderTopCustomersTo(customers, '#top-customers-body');
}

const AVATAR_COLORS = [
  { bg: '#EDE9FE', color: '#5B21B6' }, // purple
  { bg: '#CCFBF1', color: '#0F766E' }, // teal
  { bg: '#DBEAFE', color: '#1D4ED8' }, // blue
  { bg: '#FFE4E6', color: '#BE123C' }, // coral
  { bg: '#FEF3C7', color: '#92400E' }, // amber
  { bg: '#D1FAE5', color: '#065F46' }, // green
];

const MEDAL_CLASSES = ['gold', 'silver', 'bronze', 'plain'];
const MEDAL_LABELS  = ['1', '2', '3', '4'];

function renderTopCustomersTo(customers, target) {
  const body = typeof target === 'string' ? qs(target) : target;
  if (!body) return;
  body.innerHTML = '';

  if (!customers.length) {
    body.innerHTML = '<div style="font-size:13px;color:var(--color-text-secondary)">No data yet.</div>';
    return;
  }

  customers.forEach((customer, index) => {
    const initials = (customer.name || 'C').split(' ').map((w) => w[0]).join('').toUpperCase().slice(0, 2);
    const avatarStyle = AVATAR_COLORS[index % AVATAR_COLORS.length];
    const medalClass  = MEDAL_CLASSES[Math.min(index, 3)];
    const medalLabel  = MEDAL_LABELS[Math.min(index, 3)];
    const row = document.createElement('div');
    row.className = 'top-customer-row';
    row.innerHTML = `
      <span class="medal-dot ${medalClass}">${medalLabel}</span>
      <span class="customer-avatar" style="background:${avatarStyle.bg};color:${avatarStyle.color}">${initials}</span>
      <div class="top-customer-info">
        <div class="top-customer-name">${customer.name || 'Customer'}</div>
        <div class="top-customer-meta">${customer.orders || 0} orders</div>
      </div>
      <div class="top-customer-spend">${customer.spend || ''}</div>
    `;
    body.appendChild(row);
  });
}

function setBookingChipActive(status) {
  qsa('#booking-status-chips [data-status]').forEach((chip) => {
    chip.classList.toggle('active', chip.dataset.status === status);
  });
}

async function loadBookingSummaries() {
  const res = await apiRequest('/admin/booking-summaries');
  if (!res.ok) return;

  const data = res.data?.data || {};
  const totals = data.by_status || {};
  const allCount = data.total ?? 0;

  qsa('[data-status-count]').forEach((el) => {
    const key = el.dataset.statusCount;
    const value = key === 'all' ? allCount : (totals[key] ?? 0);
    setText(el, value);
  });
}

function getStepForOrder(orderId, statusValue) {
  const initial = statusToStep(statusValue);

  if (statusValue === 'ready' || statusValue === 'completed') {
    state.bookings.steps[orderId] = initial;
    return initial;
  }

  if (state.bookings.steps[orderId] !== undefined) {
    return state.bookings.steps[orderId];
  }

  if (initial !== null) {
    state.bookings.steps[orderId] = initial;
    return initial;
  }

  return null;
}

function renderStepChips(orderId, currentStep) {
  if (currentStep === null) return '';
  const steps = ['Washing', 'Drying', 'Ready', 'Done'];
  return steps.map((label, index) => {
    const active = index === currentStep ? 'active' : '';
    return `<button class="step-chip ${active}" data-booking-step="${index}" data-order-id="${orderId}" type="button">${label}</button>`;
  }).join('');
}

function renderBookingActions(orderId, statusValue) {
  const actions = [];
  if (statusValue === 'pending') {
    actions.push(`<button class="button-outline btn-sm btn-success" data-booking-action="accept" data-order-id="${orderId}" type="button">Accept</button>`);
    actions.push(`<button class="button-outline btn-sm btn-danger" data-booking-action="decline" data-order-id="${orderId}" type="button">Decline</button>`);
  }

  if (statusValue === 'ongoing' || statusValue === 'ready') {
    actions.push(`<button class="button-outline btn-sm btn-success" data-booking-action="complete" data-order-id="${orderId}" type="button">Complete</button>`);
  }

  return actions.join('');
}

function openBookingModal(orderId) {
  const orderKey = String(orderId);
  const order = state.bookings.byId[orderKey];
  if (!order) return;

  state.bookings.activeOrderId = orderKey;
  const modal = qs('#booking-modal');
  const overlay = qs('#booking-modal-overlay');
  const body = qs('#booking-modal-body');
  const title = qs('#booking-modal-title');
  const subtitle = qs('#booking-modal-subtitle');

  const orderDisplayId = formatOrderDisplayId(order);
  const statusValue = normalizeStatus(order.status) || 'pending';

  if (title) title.textContent = 'Booking details';
  if (subtitle) subtitle.textContent = `${orderDisplayId} · ${statusValue}`;
  if (body) body.innerHTML = renderBookingDetailsContent(order);

  if (overlay) overlay.classList.add('show');
  if (modal) {
    modal.classList.add('show');
    modal.classList.remove('hidden');
  }
}

function closeBookingModal() {
  state.bookings.activeOrderId = null;
  qs('#booking-modal-overlay')?.classList.remove('show');
  const modal = qs('#booking-modal');
  if (modal) {
    modal.classList.remove('show');
    modal.classList.add('hidden');
  }
}

function handleBookingAction(action) {
  const orderId = action.dataset.orderId;
  const actionType = action.dataset.bookingAction;
  if (actionType === 'accept') {
    state.bookings.steps[orderId] = 0;
    updateOrderStatus(orderId, 'ongoing');
  } else if (actionType === 'decline') {
    updateOrderStatus(orderId, 'cancelled');
  } else if (actionType === 'complete') {
    state.bookings.steps[orderId] = 3;
    updateOrderStatus(orderId, 'completed');
  }
}

function handleBookingStep(step) {
  const orderId = step.dataset.orderId;
  const stepIndex = Number(step.dataset.bookingStep);
  if (Number.isNaN(stepIndex)) return;
  state.bookings.steps[orderId] = stepIndex;
  updateOrderStatus(orderId, stepToStatus(stepIndex));
}

async function loadBookings() {
  const summaryPromise = loadBookingSummaries();
  const bookingsFilter = qs('#bookings-filter');
  if (bookingsFilter) bookingsFilter.value = state.bookings.status;
  const params = new URLSearchParams({
    page: state.bookings.page.toString(),
    per_page: state.bookings.perPage.toString(),
  });

  if (state.bookings.status && state.bookings.status !== 'all') {
    params.set('status', state.bookings.status);
  }

  const res = await apiRequest(`/admin/orders?${params.toString()}`);
  const body = qs('#bookings-table-body');
  if (!body) return;
  body.innerHTML = '';

  if (!res.ok) {
    body.innerHTML = '<tr><td colspan="8">Unable to load bookings.</td></tr>';
    return;
  }

  const orders = res.data?.data || [];
  const pagination = res.data?.pagination || {};
  state.bookings.byId = {};

  if (!orders.length) {
    body.innerHTML = '<tr><td colspan="8">No bookings found.</td></tr>';
    await summaryPromise;
    setBookingChipActive(state.bookings.status);
    return;
  }

  orders.forEach((order) => {
    const orderId = order.order_id || order.id;
    const orderKey = String(orderId);
    state.bookings.byId[orderKey] = order;
    const statusValue = normalizeStatus(order.status);
    const currentStep = getStepForOrder(orderId, statusValue);
    const row = document.createElement('tr');
    
    const initials = (order.customer_name || 'Customer').split(' ').map((n) => n[0]).join('').substring(0, 2).toUpperCase();
    const formattedDate = formatDate(order.created_at);

    const orderDisplayId = formatOrderDisplayId(order);
    
    const colors = [
      { bg: '#EEEDFE', color: '#3C3489' },
      { bg: '#E1F5EE', color: '#085041' },
      { bg: '#E6F1FB', color: '#0C447C' }
    ];
    const avatarStyle = colors[(order.customer_id || 0) % colors.length];

    row.innerHTML = `
      <td><span class="order-id">${orderDisplayId}</span></td>
      <td>
        <div class="order-customer-cell">
          <span class="order-customer-avatar" style="background:${avatarStyle.bg};color:${avatarStyle.color}">${initials}</span>
          <span class="order-customer-name">${order.customer_name || 'Unknown'}</span>
        </div>
      </td>
      <td>${order.service_type || 'Service'}</td>
      <td>${order.weight_kg || 0} kg</td>
      <td>${formatCurrency(order.total_price || 0)}</td>
      <td>
        <span class="status-pill" data-status="${statusValue}">
          <span class="status-dot"></span>
          ${statusValue}
        </span>
      </td>
      <td><span class="order-created-date">${formattedDate}</span></td>
      <td>
        <div style="display:flex; gap:6px; align-items:center;">
          <button class="btn-action-pill btn-action-details" data-booking-toggle="${orderId}" type="button">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            Details
          </button>
          <button class="btn-action-pill btn-action-receipt" data-cod-receipt-id="${orderId}" type="button">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
            Receipt
          </button>
        </div>
      </td>
    `;
    body.appendChild(row);

  });

  const totalOrders = pagination.total || orders.length;
  setText('#bookings-footer-info', `Showing ${orders.length} of ${totalOrders} orders — Page ${pagination.current_page || 1} of ${pagination.last_page || 1}`);
  const prev = qs('#bookings-prev');
  const next = qs('#bookings-next');
  const currentPageBtn = qs('#bookings-current-page');
  
  if (prev) prev.disabled = (pagination.current_page || 1) <= 1;
  if (next) next.disabled = (pagination.current_page || 1) >= (pagination.last_page || 1);
  if (currentPageBtn) currentPageBtn.textContent = pagination.current_page || 1;

  await summaryPromise;
  setBookingChipActive(state.bookings.status);
}

function renderStatusOptions(current) {
  const statuses = ['pending', 'ongoing', 'ready', 'completed', 'cancelled'];
  return statuses.map((status) => {
    const selected = status === current ? 'selected' : '';
    return `<option value="${status}" ${selected}>${status}</option>`;
  }).join('');
}

async function updateOrderStatus(orderId, status) {
  const orderKey = String(orderId);

  const res = await apiRequest(`/admin/orders/${orderId}/status`, {
    method: 'PATCH',
    body: { status },
  });

  if (!res.ok) {
    showToast('Unable to update status.');
    return;
  }

  showToast('Order status updated.');
  const updatedOrder = res.data?.data;
  await loadBookings();

  if (updatedOrder) {
    state.bookings.byId[orderKey] = updatedOrder;
  }

  if (state.bookings.activeOrderId === orderKey) openBookingModal(orderId);
}

async function loadCustomers() {
  const params = new URLSearchParams({
    page: state.customers.page.toString(),
    per_page: state.customers.perPage.toString(),
  });

  if (state.customers.search) {
    params.set('search', state.customers.search);
  }

  const res = await apiRequest(`/admin/customers?${params.toString()}`);
  const body = qs('#customers-table-body');
  if (!body) return;
  body.innerHTML = '';

  if (!res.ok) {
    body.innerHTML = '<tr><td colspan="6">Unable to load customers.</td></tr>';
    return;
  }

  const customers = res.data?.data || [];
  const pagination = res.data?.pagination || {};

  if (!customers.length) {
    body.innerHTML = '<tr><td colspan="6">No customers found.</td></tr>';
  }

  customers.forEach((customer) => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>
        <div class="font-semibold">${customer.name || 'Customer'}</div>
        <div class="text-xs text-slate-500">${customer.email || ''}</div>
      </td>
      <td>${customer.phone || '---'}</td>
      <td>${customer.orders_count || 0}</td>
      <td>${formatCurrency(customer.total_spent || 0)}</td>
      <td>${customer.loyalty_points || 0}</td>
      <td>
        <button class="button-outline" data-customer-id="${customer.id}">View</button>
      </td>
    `;
    body.appendChild(row);
  });

  setText('#customers-page-info', `Page ${pagination.current_page || 1} of ${pagination.last_page || 1}`);
  const prev = qs('#customers-prev');
  const next = qs('#customers-next');
  if (prev) prev.disabled = (pagination.current_page || 1) <= 1;
  if (next) next.disabled = (pagination.current_page || 1) >= (pagination.last_page || 1);
}

async function openCustomerDrawer(customerId) {
  state.currentCustomerId = customerId;
  qs('#customer-drawer')?.classList.add('open');
  qs('#drawer-overlay')?.classList.add('show');
  setText('#customer-drawer-title', 'Loading...');

  const profileRes = await apiRequest(`/admin/customers/${customerId}`);

  if (!profileRes.ok) {
    showToast('Unable to load customer.');
    return;
  }

  const profile = profileRes.data?.data || {};
  setText('#customer-drawer-title', profile.name || 'Customer');
  qs('#customer-name').value = profile.name || '';
  qs('#customer-email').value = profile.email || '';
  qs('#customer-phone').value = profile.phone || '';
  qs('#customer-address').value = profile.address || '';
  qs('#customer-city').value = profile.city || '';
  qs('#customer-zip').value = profile.zip_code || '';
  qs('#customer-country').value = profile.country || '';
  qs('#customer-notifications').checked = profile.notifications_enabled !== false;
  setText('#customer-loyalty', profile.loyalty_points || 0);
  setText('#customer-orders-count', profile.orders_count || 0);
  setText('#customer-total-spent', formatCurrency(profile.total_spent || 0));

  setText('#customer-dob', formatValue(formatDate(profile.date_of_birth)));
  setText('#customer-gender', formatValue(profile.gender));
  setText('#customer-language', formatValue(profile.preferred_language));
  setText('#customer-email-verified', formatYesNo(!!profile.email_verified_at));
  setText('#customer-profile-completed', formatYesNo(!!profile.profile_completed_at));
  setText('#customer-member-since', formatValue(formatDate(profile.created_at)));
  setText('#customer-last-login', formatValue(formatDate(profile.last_login_at)));
  setText('#customer-bio', formatValue(profile.bio));

  state.customerOrders.page = 1;
  state.customerOrders.lastPage = 1;
  await loadCustomerOrders(true);
}

function closeCustomerDrawer() {
  qs('#customer-drawer')?.classList.remove('open');
  qs('#drawer-overlay')?.classList.remove('show');
  state.currentCustomerId = null;
}

async function saveCustomerProfile() {
  if (!state.currentCustomerId) return;

  const payload = {
    name: qs('#customer-name').value.trim(),
    phone: qs('#customer-phone').value.trim() || null,
    address: qs('#customer-address').value.trim() || null,
    city: qs('#customer-city').value.trim() || null,
    zip_code: qs('#customer-zip').value.trim() || null,
    country: qs('#customer-country').value.trim() || null,
    notifications_enabled: qs('#customer-notifications').checked,
  };

  const res = await apiRequest(`/admin/customers/${state.currentCustomerId}`, {
    method: 'PUT',
    body: payload,
  });

  if (!res.ok) {
    showToast('Unable to update customer.');
    return;
  }

  showToast('Customer updated.');
  await loadCustomers();
}

async function loadCustomerOrders(reset = false) {
  if (!state.currentCustomerId) return;

  if (reset) {
    state.customerOrders.page = 1;
  }

  const params = new URLSearchParams({
    page: state.customerOrders.page.toString(),
    per_page: state.customerOrders.perPage.toString(),
  });

  const res = await apiRequest(`/admin/customers/${state.currentCustomerId}/orders?${params.toString()}`);
  const body = qs('#customer-orders-body');
  if (!body) return;

  if (!res.ok) {
    if (reset) {
      body.innerHTML = '<tr><td colspan="5">Unable to load orders.</td></tr>';
    }
    return;
  }

  const orders = res.data?.data || [];
  const pagination = res.data?.pagination || {};

  if (reset) {
    body.innerHTML = '';
  }

  if (!orders.length && reset) {
    body.innerHTML = '<tr><td colspan="5">No orders yet.</td></tr>';
  }

  orders.forEach((order) => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>${order.id || ''}</td>
      <td>${order.service_type || ''}</td>
      <td>${order.weight_kg || 0} kg</td>
      <td>${formatCurrency(order.total_price || 0)}</td>
      <td>${order.status || ''}</td>
    `;
    body.appendChild(row);
  });

  state.customerOrders.lastPage = pagination.last_page || 1;
  const currentPage = pagination.current_page || state.customerOrders.page;
  setText('#customer-orders-page-info', `Page ${currentPage} of ${state.customerOrders.lastPage}`);

  const totalOrders = Number.isFinite(pagination.total) ? pagination.total : orders.length;
  setText('#customer-orders-title-count', `(${totalOrders})`);

  const loadMore = qs('#customer-orders-load');
  if (loadMore) {
    const atEnd = currentPage >= state.customerOrders.lastPage;
    loadMore.disabled = atEnd;
    loadMore.classList.toggle('hidden', atEnd || totalOrders === 0);
  }
}

async function loadAnalytics() {
  const res = await apiRequest('/admin/analytics');
  if (!res.ok) {
    showToast('Unable to load analytics.');
    return;
  }

  const data = res.data || {};
  const monthlyRevenue = Number(data.monthly_revenue || 0);
  const totalOrdersThisMonth = Number(data.total_orders_this_month || 0);
  const completedOrdersThisMonth = Number(data.completed_orders_this_month || 0);
  const cancelledOrdersThisMonth = Number(data.cancelled_orders_this_month || 0);
  const newCustomersThisMonth = Number(data.new_customers_this_month || 0);
  const totalCustomers = Number(data.total_customers || 0);
  const completionRate = Number(data.completion_rate || 0);
  const topService = data.top_service || null;
  const topCustomers = Array.isArray(data.top_customers) ? data.top_customers : [];
  const bestCustomer = topCustomers[0] || null;

  setText('#analytics-month', data.month_label || '');
  setText('#analytics-monthly-revenue', formatCurrency(monthlyRevenue));
  setText('#analytics-monthly-card', formatCurrency(monthlyRevenue));
  setText('#analytics-completion-rate', `${completionRate}%`);
  setText('#analytics-monthly-orders', totalOrdersThisMonth);
  setText('#analytics-new-customers', newCustomersThisMonth);
  setText('#analytics-total-customers', `${totalCustomers} total customers`);
  setText('#analytics-completed-orders', completedOrdersThisMonth);
  setText('#analytics-cancelled-orders', `${cancelledOrdersThisMonth} cancelled`);
  setText('#analytics-top-service', topService?.name || 'No service data yet');
  setText('#analytics-top-service-meta', topService ? `${topService.orders || 0} orders` : 'No completed order mix yet');
  setText('#analytics-top-customer', bestCustomer?.name || 'No customer data yet');
  setText(
    '#analytics-top-customer-meta',
    bestCustomer ? `${bestCustomer.orders || 0} orders · ${bestCustomer.spend_label || formatCurrency(bestCustomer.spend || 0)}` : 'No customer orders yet'
  );
  setText('#analytics-order-health', `${completionRate}% completion`);

  const weekly = data.weekly_revenue || [];
  const max = Math.max(1, ...weekly.map((value) => Number(value || 0)));
  const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  const weeklyContainer = qs('#weekly-bars');
  weeklyContainer.innerHTML = '';

  weekly.forEach((value, index) => {
    const height = Math.round((Number(value || 0) / max) * 100);
    const bar = document.createElement('div');
    bar.className = 'weekly-bar';
    bar.innerHTML = `
      <div class="weekly-bar-value">${formatCurrency(Number(value || 0))}</div>
      <div class="weekly-bar-track" title="${formatCurrency(Number(value || 0))}">
        <div class="weekly-bar-fill" style="height:${height}%;"></div>
      </div>
      <div class="weekly-bar-label">${dayLabels[index] || ''}</div>
    `;
    weeklyContainer.appendChild(bar);
  });

  const breakdown = data.service_breakdown || [];
  const breakdownBody = qs('#service-breakdown-body');
  const breakdownDonut = qs('#service-breakdown-donut');
  const breakdownTotal = qs('#service-breakdown-total');
  if (breakdownBody) breakdownBody.innerHTML = '';

  const palette = ['#3B82F6', '#34D399', '#F59E0B', '#EC4899', '#A78BFA', '#22D3EE'];
  let accumulator = 0;
  let pctTotal = 0;
  const segments = [];

  if (!breakdown.length) {
    if (breakdownBody) {
      breakdownBody.innerHTML = '<div class="analytics-empty">No service data yet.</div>';
    }
    if (breakdownDonut) {
      breakdownDonut.style.background = 'conic-gradient(rgba(148, 163, 184, 0.2) 0% 100%)';
    }
    if (breakdownTotal) setText('#service-breakdown-total', '0%');
  } else {
    breakdown.forEach((item, index) => {
      const pct = Math.max(0, Math.min(100, Number(item.pct || 0)));
      const color = palette[index % palette.length];
      if (pct > 0) {
        segments.push(`${color} ${accumulator}% ${accumulator + pct}%`);
      }
      accumulator += pct;
      pctTotal += pct;

      if (breakdownBody) {
        const row = document.createElement('div');
        row.className = 'breakdown-legend-row';
        row.innerHTML = `
          <span class="breakdown-legend-swatch" style="background:${color};"></span>
          <div class="breakdown-legend-copy">
            <div class="breakdown-legend-name">${escapeHtml(item.name || 'Service')}</div>
            <div class="breakdown-legend-meta">${pct}% &middot; ${item.count || 0} orders</div>
          </div>
        `;
        breakdownBody.appendChild(row);
      }
    });

    if (breakdownDonut) {
      const safeTotal = Math.min(100, Math.round(pctTotal));
      if (pctTotal < 100) {
        segments.push(`rgba(148, 163, 184, 0.2) ${pctTotal}% 100%`);
      }
      breakdownDonut.style.background = `conic-gradient(${segments.join(', ')})`;
      if (breakdownTotal) setText('#service-breakdown-total', `${safeTotal}%`);
    }
  }

  const topCustomersList = qs('#analytics-top-customers-list');
  if (topCustomersList) {
    topCustomersList.innerHTML = '';
    if (!topCustomers.length) {
      topCustomersList.innerHTML = '<div class="analytics-empty">No customer spend data yet.</div>';
    } else {
      topCustomers.forEach((customer, index) => {
        const row = document.createElement('div');
        row.className = 'analytics-customer-row';
        row.innerHTML = `
          <span class="analytics-rank">${index + 1}</span>
          <div class="analytics-customer-copy">
            <strong>${escapeHtml(customer.name || 'Customer')}</strong>
            <span>${customer.orders || 0} orders</span>
          </div>
          <div class="analytics-customer-spend">${customer.spend_label || formatCurrency(customer.spend || 0)}</div>
        `;
        topCustomersList.appendChild(row);
      });
    }
  }
}

async function loadServices() {
  const [res, topRes] = await Promise.all([
    apiRequest('/admin/services'),
    apiRequest('/admin/top-customers'),
  ]);
  const body = qs('#services-table-body');
  if (!body) return;
  body.innerHTML = '';

  if (!res.ok) {
    body.innerHTML = '<tr><td colspan="6">Unable to load services.</td></tr>';
    renderTopCustomersTo(topRes.ok ? topRes.data?.data || [] : [], '#services-top-customers-body');
    return;
  }

  const services = res.data?.data || [];

  if (!services.length) {
    body.innerHTML = '<tr><td colspan="6">No services found.</td></tr>';
  }

  services.forEach((service) => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>
        <div class="font-semibold">${service.name || 'Service'}</div>
        <div class="text-xs text-slate-500">${service.description || ''}</div>
      </td>
      <td>${formatCurrency(service.price_per_kg || 0)}</td>
      <td>${service.category || '---'}</td>
      <td>${service.is_active ? 'Active' : 'Inactive'}</td>
      <td class="space-x-2">
        <button class="button-outline" data-edit-service="${service.id}">Edit</button>
        <button class="button-outline" data-delete-service="${service.id}">Delete</button>
      </td>
    `;
    body.appendChild(row);
  });

  renderTopCustomersTo(topRes.ok ? topRes.data?.data || [] : [], '#services-top-customers-body');
}

async function saveService() {
  const payload = {
    name: qs('#service-name').value.trim(),
    description: qs('#service-description').value.trim() || null,
    price_per_kg: Number(qs('#service-price').value || 0),
    category: qs('#service-category').value.trim() || null,
    image_url: qs('#service-image').value.trim() || null,
    is_active: qs('#service-active').checked,
  };

  const editingId = state.services.editingId;
  const res = await apiRequest(`/admin/services${editingId ? `/${editingId}` : ''}`,
    {
      method: editingId ? 'PUT' : 'POST',
      body: payload,
    },
  );

  if (!res.ok) {
    showToast('Unable to save service.');
    return;
  }

  showToast(editingId ? 'Service updated.' : 'Service created.');
  resetServiceForm();
  await loadServices();
}

function resetServiceForm() {
  state.services.editingId = null;
  setText('#service-form-title', 'Create service');
  qs('#service-name').value = '';
  qs('#service-description').value = '';
  qs('#service-price').value = '';
  qs('#service-category').value = '';
  qs('#service-image').value = '';
  qs('#service-active').checked = true;
}

async function handleServiceEdit(serviceId) {
  const res = await apiRequest('/admin/services');
  if (!res.ok) return;

  const services = res.data?.data || [];
  const service = services.find((item) => item.id === Number(serviceId));
  if (!service) return;

  state.services.editingId = service.id;
  setText('#service-form-title', 'Update service');
  qs('#service-name').value = service.name || '';
  qs('#service-description').value = service.description || '';
  qs('#service-price').value = service.price_per_kg || '';
  qs('#service-category').value = service.category || '';
  qs('#service-image').value = service.image_url || '';
  qs('#service-active').checked = service.is_active !== false;
}

async function handleServiceDelete(serviceId) {
  const confirmed = window.confirm('Delete this service?');
  if (!confirmed) return;

  const res = await apiRequest(`/admin/services/${serviceId}`, { method: 'DELETE' });
  if (!res.ok) {
    showToast('Unable to delete service.');
    return;
  }

  showToast('Service deleted.');
  await loadServices();
}

function setPasswordVisibility(loginPassword, togglePassword, shouldShowPassword) {
  loginPassword.type = shouldShowPassword ? 'text' : 'password';
  togglePassword.setAttribute('aria-pressed', shouldShowPassword ? 'true' : 'false');
  togglePassword.setAttribute('aria-label', shouldShowPassword ? 'Hide password' : 'Show password');
  togglePassword.innerHTML = shouldShowPassword
    ? '<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>'
    : '<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>';
}

function bindEvents() {
  const loginForm = qs('#login-form');
  if (loginForm) loginForm.addEventListener('submit', handleLogin);

  const togglePassword = qs('#toggle-password');
  const loginPassword = qs('#login-password');
  if (togglePassword && loginPassword) {
    setPasswordVisibility(loginPassword, togglePassword, false);
    togglePassword.addEventListener('click', () => {
      const shouldShowPassword = loginPassword.type === 'password';
      setPasswordVisibility(loginPassword, togglePassword, shouldShowPassword);
    });
  }

  const logoutButton = qs('#logout-button');
  if (logoutButton) logoutButton.addEventListener('click', handleLogout);
  const logoutModalCancel = qs('#logout-modal-cancel');
  if (logoutModalCancel) logoutModalCancel.addEventListener('click', closeLogoutModal);
  const logoutModalConfirm = qs('#logout-modal-confirm');
  if (logoutModalConfirm) logoutModalConfirm.addEventListener('click', confirmLogout);
  const logoutModalOverlay = qs('#logout-modal-overlay');
  if (logoutModalOverlay) logoutModalOverlay.addEventListener('click', closeLogoutModal);

  qsa('[data-view]').forEach((link) => {
    link.addEventListener('click', () => {
      setActiveView(link.dataset.view);
      closeSidebar();
    });
  });

  const bookingsFilter = qs('#bookings-filter');
  if (bookingsFilter) {
    bookingsFilter.addEventListener('change', (event) => {
      state.bookings.status = event.target.value;
      state.bookings.page = 1;
      setBookingChipActive(state.bookings.status);
      loadBookings();
    });
  }

  const bookingChips = qs('#booking-status-chips');
  if (bookingChips) {
    bookingChips.addEventListener('click', (event) => {
      const chip = event.target.closest('[data-status]');
      if (!chip) return;
      state.bookings.status = chip.dataset.status;
      state.bookings.page = 1;
      setBookingChipActive(state.bookings.status);
      if (bookingsFilter) bookingsFilter.value = state.bookings.status;
      loadBookings();
    });
  }

  const bookingsPrev = qs('#bookings-prev');
  if (bookingsPrev) {
    bookingsPrev.addEventListener('click', () => {
      state.bookings.page = Math.max(1, state.bookings.page - 1);
      loadBookings();
    });
  }

  const bookingsNext = qs('#bookings-next');
  if (bookingsNext) {
    bookingsNext.addEventListener('click', () => {
      state.bookings.page += 1;
      loadBookings();
    });
  }

  const bookingsTable = qs('#bookings-table-body');
  if (bookingsTable) {
    bookingsTable.addEventListener('change', (event) => {
      const select = event.target.closest('select[data-order-id]');
      if (!select) return;
      updateOrderStatus(select.dataset.orderId, select.value);
    });

    bookingsTable.addEventListener('click', (event) => {
      const receiptBtn = event.target.closest('[data-cod-receipt-id]');
      if (receiptBtn) {
        const orderId = receiptBtn.dataset.codReceiptId;
        const order = state.bookings.byId[String(orderId)];
        if (order) {
          openCodReceipt(order);
        } else {
          showToast('Receipt data unavailable. Please refresh.');
        }
        return;
      }

      const toggle = event.target.closest('[data-booking-toggle]');
      if (toggle) {
        const orderId = toggle.dataset.bookingToggle;
        openBookingModal(orderId);
        return;
      }

      const action = event.target.closest('[data-booking-action]');
      if (action) {
        handleBookingAction(action);
        return;
      }

      const step = event.target.closest('[data-booking-step]');
      if (step) {
        handleBookingStep(step);
      }
    });
  }

  const bookingModalClose = qs('#booking-modal-close');
  if (bookingModalClose) bookingModalClose.addEventListener('click', closeBookingModal);

  const bookingModal = qs('#booking-modal');
  if (bookingModal) {
    bookingModal.addEventListener('click', (event) => {
      const action = event.target.closest('[data-booking-action]');
      if (action) {
        handleBookingAction(action);
        return;
      }

      const step = event.target.closest('[data-booking-step]');
      if (step) {
        handleBookingStep(step);
      }
    });
  }

  const customersSearchButton = qs('#customers-search-button');
  if (customersSearchButton) {
    customersSearchButton.addEventListener('click', () => {
      state.customers.search = qs('#customers-search-input').value.trim();
      state.customers.page = 1;
      loadCustomers();
    });
  }

  const customersPrev = qs('#customers-prev');
  if (customersPrev) {
    customersPrev.addEventListener('click', () => {
      state.customers.page = Math.max(1, state.customers.page - 1);
      loadCustomers();
    });
  }

  const customersNext = qs('#customers-next');
  if (customersNext) {
    customersNext.addEventListener('click', () => {
      state.customers.page += 1;
      loadCustomers();
    });
  }

  const customersTable = qs('#customers-table-body');
  if (customersTable) {
    customersTable.addEventListener('click', (event) => {
      const button = event.target.closest('[data-customer-id]');
      if (!button) return;
      openCustomerDrawer(button.dataset.customerId);
    });
  }

  const customerDrawerClose = qs('#customer-drawer-close');
  if (customerDrawerClose) customerDrawerClose.addEventListener('click', closeCustomerDrawer);

  const drawerOverlay = qs('#drawer-overlay');
  if (drawerOverlay) drawerOverlay.addEventListener('click', closeCustomerDrawer);

  const customerSave = qs('#customer-save');
  if (customerSave) customerSave.addEventListener('click', saveCustomerProfile);

  const customerOrdersLoad = qs('#customer-orders-load');
  if (customerOrdersLoad) {
    customerOrdersLoad.addEventListener('click', () => {
      if (state.customerOrders.page >= state.customerOrders.lastPage) return;
      state.customerOrders.page += 1;
      loadCustomerOrders();
    });
  }

  const serviceSave = qs('#service-save');
  if (serviceSave) serviceSave.addEventListener('click', saveService);

  const serviceClear = qs('#service-clear');
  if (serviceClear) serviceClear.addEventListener('click', resetServiceForm);

  const servicesTable = qs('#services-table-body');
  if (servicesTable) {
    servicesTable.addEventListener('click', (event) => {
      const edit = event.target.closest('[data-edit-service]');
      if (edit) {
        handleServiceEdit(edit.dataset.editService);
        return;
      }

      const del = event.target.closest('[data-delete-service]');
      if (del) {
        handleServiceDelete(del.dataset.deleteService);
      }
    });
  }

  const recentOrdersViewAll = qs('#recent-orders-view-all');
  if (recentOrdersViewAll) recentOrdersViewAll.addEventListener('click', () => setActiveView('bookings'));

  const sidebarToggle = qs('#sidebar-toggle');
  if (sidebarToggle) sidebarToggle.addEventListener('click', toggleSidebar);

  const sidebarOverlay = qs('#sidebar-overlay');
  if (sidebarOverlay) sidebarOverlay.addEventListener('click', closeSidebar);

  // COD Receipt close buttons
  const codReceiptClose = qs('#cod-receipt-close');
  if (codReceiptClose) codReceiptClose.addEventListener('click', closeCodReceipt);

  const codReceiptCancel = qs('#cod-receipt-cancel');
  if (codReceiptCancel) codReceiptCancel.addEventListener('click', closeCodReceipt);

  const codReceiptPrint = qs('#cod-receipt-print');
  if (codReceiptPrint) codReceiptPrint.addEventListener('click', printCodReceipt);

  const codReceiptOverlay = qs('#cod-receipt-overlay');
  if (codReceiptOverlay) codReceiptOverlay.addEventListener('click', closeCodReceipt);
}

window.addEventListener('DOMContentLoaded', () => {
  bindEvents();
  bootstrapApp();
});

// ── COD Receipt ─────────────────────────────────────────

function openCodReceipt(order) {
  const modal   = qs('#cod-receipt-modal');
  const overlay = qs('#cod-receipt-overlay');
  const body    = qs('#cod-receipt-body');
  if (!modal || !overlay || !body) return;

  const displayId        = formatOrderDisplayId(order);
  const deliveryTypeLabel = formatDeliveryType(order.delivery_type);
  const pickupDate       = formatDate(order.pickup_date);
  const deliveryDate     = formatDate(order.delivery_date);
  const createdAt        = formatDate(order.created_at);
  const totalFormatted   = formatCurrency(order.total_price || 0);
  const now              = new Date().toLocaleDateString('en-PH', { month: 'short', day: 'numeric', year: 'numeric' });

  const row = (label, value, icon = '') => `
    <tr>
      <td style="padding:9px 12px; color:#58708D; font-size:12px; font-weight:500; width:42%; white-space:nowrap; vertical-align:middle;">
        ${icon ? `<span style="margin-right:5px; opacity:0.7;">${icon}</span>` : ''}${label}
      </td>
      <td style="padding:9px 12px; color:#08213D; font-size:12.5px; font-weight:600; vertical-align:middle;">${value}</td>
    </tr>`;

  body.innerHTML = `
    <div id="cod-receipt-print-area" style="font-family:'Segoe UI',Arial,sans-serif; color:#08213D; background:#fff;">

      <!-- Branded Header -->
      <div style="background:linear-gradient(135deg,#1565C0 0%,#0D47A1 100%); padding:22px 24px 20px; text-align:center; position:relative; overflow:hidden;">
        <div style="position:absolute;top:-18px;right:-18px;width:90px;height:90px;border-radius:50%;background:rgba(255,255,255,0.07);"></div>
        <div style="position:absolute;bottom:-24px;left:-12px;width:70px;height:70px;border-radius:50%;background:rgba(255,255,255,0.05);"></div>
        <div style="font-size:10px; font-weight:800; letter-spacing:0.22em; text-transform:uppercase; color:rgba(255,255,255,0.65); margin-bottom:6px;">LaundryHub</div>
        <div style="font-size:24px; font-weight:800; color:#fff; letter-spacing:-0.5px; margin-bottom:4px;">Cash on Delivery Receipt</div>
        <div style="display:inline-block; background:rgba(255,255,255,0.15); border-radius:20px; padding:3px 14px; font-size:12px; font-weight:700; color:#fff; letter-spacing:0.05em;">${displayId}</div>
        <div style="margin-top:6px; font-size:11px; color:rgba(255,255,255,0.55);">Issued: ${now}</div>
      </div>

      <!-- Detail Rows -->
      <div style="padding:4px 0;">
        <table style="width:100%; border-collapse:collapse;">
          <tbody>
            <tr style="background:#F8FBFF;">
              <td colspan="2" style="padding:7px 12px; font-size:10px; font-weight:800; letter-spacing:0.12em; text-transform:uppercase; color:#58708D;">Customer Info</td>
            </tr>
            ${row('Customer', escapeHtml(order.customer_name || 'N/A'), '👤')}
            ${row('Address',  escapeHtml(order.pickup_address || 'N/A'), '📍')}
            <tr style="background:#F8FBFF;">
              <td colspan="2" style="padding:7px 12px; font-size:10px; font-weight:800; letter-spacing:0.12em; text-transform:uppercase; color:#58708D;">Order Details</td>
            </tr>
            ${row('Service',     escapeHtml(order.service_type || '---'), '🧺')}
            ${row('Weight',      `${order.weight_kg || 0} kg`, '⚖️')}
            ${row('Fulfillment', deliveryTypeLabel, '🚚')}
            ${row('Pickup Date',   pickupDate, '📅')}
            ${row('Delivery Date', deliveryDate, '📅')}
            ${row('Order Date',    createdAt, '🗓️')}
          </tbody>
        </table>
      </div>

      <!-- Total Banner -->
      <div style="margin:0 16px 16px; background:linear-gradient(135deg,#EEF4FF 0%,#E8F0FE 100%); border:1px solid rgba(21,101,192,0.18); border-radius:10px; padding:16px 20px; display:flex; align-items:center; justify-content:space-between;">
        <div>
          <div style="font-size:10px; font-weight:700; letter-spacing:0.10em; text-transform:uppercase; color:#58708D; margin-bottom:2px;">Total Amount Due</div>
          <div style="font-size:26px; font-weight:800; color:#1565C0; letter-spacing:-0.5px;">${totalFormatted}</div>
        </div>
        <div style="width:48px; height:48px; border-radius:50%; background:rgba(21,101,192,0.1); display:flex; align-items:center; justify-content:center; font-size:22px;">💳</div>
      </div>

      <!-- COD Badge -->
      <div style="margin:0 16px 20px; background:linear-gradient(135deg,#E8F5E9 0%,#F1F8E9 100%); border:1px solid rgba(46,125,50,0.20); border-radius:10px; padding:13px 16px; display:flex; align-items:center; gap:12px;">
        <div style="width:36px; height:36px; border-radius:50%; background:#2E7D32; display:flex; align-items:center; justify-content:center; flex-shrink:0; font-size:17px;">✓</div>
        <div>
          <div style="font-size:13px; font-weight:700; color:#1B5E20; margin-bottom:2px;">Cash on Delivery (COD)</div>
          <div style="font-size:11px; color:#388E3C; line-height:1.4;">Payment is collected at the time of delivery or pickup by our laundry staff.</div>
        </div>
      </div>

    </div>
  `;

  modal.classList.remove('hidden');
  modal.classList.add('show');
  overlay.classList.add('show');
}

function closeCodReceipt() {
  const modal   = qs('#cod-receipt-modal');
  const overlay = qs('#cod-receipt-overlay');
  if (modal)   { modal.classList.remove('show'); modal.classList.add('hidden'); }
  if (overlay) { overlay.classList.remove('show'); }
}

function printCodReceipt() {
  // Read order data from the live modal to build a self-contained print document.
  const modal = qs('#cod-receipt-modal');
  if (!modal || modal.classList.contains('hidden')) {
    showToast('Open a receipt first.');
    return;
  }

  // Grab text content from the rendered receipt body.
  const get = (sel) => (modal.querySelector(sel)?.textContent?.trim() || '---');

  // Pull all <td> label+value pairs from the detail table
  const rows = Array.from(modal.querySelectorAll('#cod-receipt-print-area table tbody tr'))
    .filter(tr => !tr.querySelector('[colspan]'))            // skip section-header rows
    .map(tr => {
      const cells = tr.querySelectorAll('td');
      if (cells.length < 2) return null;
      // strip the emoji from the label cell
      const label = cells[0].textContent.replace(/[\u{1F000}-\u{1FFFF}]/gu, '').trim();
      const value = cells[1].textContent.trim();
      return { label, value };
    })
    .filter(Boolean);

  // Order ID and total from the header / total banner
  const orderId = modal.querySelector('.btn-action-receipt')?.dataset?.codReceiptId || '';
  const headerEl    = modal.querySelector('#cod-receipt-print-area > div:first-child');
  const headerLines = headerEl ? headerEl.querySelectorAll('div') : [];
  // The displayId is in the inline-block pill (3rd div inside header)
  const displayId   = headerLines[2]?.textContent?.trim() || '';
  const issuedLine  = headerLines[3]?.textContent?.trim() || '';
  const totalEl     = modal.querySelector('#cod-receipt-print-area [style*="font-size:26px"]');
  const totalText   = totalEl?.textContent?.trim() || '';

  const rowsHtml = rows.map(({ label, value }) => `
    <tr>
      <td class="label-col">${label}</td>
      <td class="value-col">${value}</td>
    </tr>`).join('');

  // Group rows into Customer Info and Order Details
  const customerLabels = ['Customer', 'Address'];
  const customerRows = rows.filter(r => customerLabels.includes(r.label));
  const orderRows    = rows.filter(r => !customerLabels.includes(r.label));

  const buildRows = (arr) => arr.map(({ label, value }) => `
    <tr>
      <td class="label">${label}</td>
      <td class="value">${value}</td>
    </tr>`).join('');

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>COD Receipt ${displayId}</title>
  <style>
    @page {
      size: A4;
      margin: 18mm 18mm 20mm;
    }
    *, *::before, *::after {
      box-sizing: border-box;
      margin: 0; padding: 0;
      print-color-adjust: exact;
      -webkit-print-color-adjust: exact;
    }
    body {
      font-family: 'Segoe UI', Arial, Helvetica, sans-serif;
      color: #08213D;
      background: #fff;
      font-size: 13px;
      line-height: 1.5;
    }
    .wrap { max-width: 520px; margin: 0 auto; }

    /* Header */
    .header {
      background: linear-gradient(135deg, #1565C0 0%, #0D47A1 100%);
      border-radius: 12px 12px 0 0;
      padding: 28px 28px 24px;
      text-align: center;
      color: #fff;
      position: relative;
      overflow: hidden;
    }
    .header::before {
      content: '';
      position: absolute; top: -28px; right: -28px;
      width: 110px; height: 110px; border-radius: 50%;
      background: rgba(255,255,255,0.07);
    }
    .header::after {
      content: '';
      position: absolute; bottom: -30px; left: -18px;
      width: 90px; height: 90px; border-radius: 50%;
      background: rgba(255,255,255,0.05);
    }
    .brand-label {
      font-size: 9px; font-weight: 800; letter-spacing: 0.24em;
      text-transform: uppercase; color: rgba(255,255,255,0.6);
      margin-bottom: 10px;
    }
    .receipt-icon {
      font-size: 28px; margin-bottom: 10px; display: block;
    }
    .title {
      font-size: 22px; font-weight: 800;
      letter-spacing: -0.4px; margin-bottom: 8px;
    }
    .order-pill {
      display: inline-block;
      background: rgba(255,255,255,0.17);
      border-radius: 20px; padding: 3px 16px;
      font-size: 12px; font-weight: 700;
    }
    .issued {
      margin-top: 6px; font-size: 10.5px; color: rgba(255,255,255,0.55);
    }

    /* Detail section */
    .section {
      padding: 0 20px;
      background: #fff;
    }
    .section-head {
      padding: 8px 0 4px;
      font-size: 9.5px; font-weight: 800;
      letter-spacing: 0.14em; text-transform: uppercase;
      color: #58708D;
      border-bottom: 1px solid rgba(21,101,192,0.10);
      margin-top: 16px;
    }
    table { width: 100%; border-collapse: collapse; }
    .label {
      padding: 8px 0; width: 42%;
      color: #58708D; font-size: 12px; font-weight: 500;
    }
    .value {
      padding: 8px 0;
      color: #08213D; font-size: 12.5px; font-weight: 600;
    }
    tr { border-bottom: 1px solid rgba(21,101,192,0.07); }
    tr:last-child { border-bottom: none; }

    /* Total */
    .total-box {
      margin: 18px 20px 0;
      background: linear-gradient(135deg, #EEF4FF, #E8F0FE);
      border: 1px solid rgba(21,101,192,0.18);
      border-radius: 10px;
      padding: 16px 20px;
      display: flex; align-items: center; justify-content: space-between;
    }
    .total-label {
      font-size: 9px; font-weight: 800;
      letter-spacing: 0.14em; text-transform: uppercase;
      color: #58708D; margin-bottom: 4px;
    }
    .total-amount {
      font-size: 28px; font-weight: 800;
      color: #1565C0; letter-spacing: -0.8px;
    }
    .total-icon {
      font-size: 26px; opacity: 0.65;
    }

    /* COD badge */
    .cod-box {
      margin: 14px 20px 0;
      background: linear-gradient(135deg, #E8F5E9, #F1F8E9);
      border: 1px solid rgba(46,125,50,0.20);
      border-radius: 10px;
      padding: 13px 16px;
      display: flex; align-items: center; gap: 12px;
    }
    .cod-circle {
      width: 36px; height: 36px; border-radius: 50%;
      background: #2E7D32; color: #fff;
      font-size: 18px; font-weight: 900;
      display: flex; align-items: center; justify-content: center;
      flex-shrink: 0;
    }
    .cod-title { font-size: 13px; font-weight: 700; color: #1B5E20; margin-bottom: 2px; }
    .cod-sub   { font-size: 11px; color: #388E3C; line-height: 1.4; }

    /* Footer */
    .receipt-footer {
      margin: 20px 20px 0;
      padding-top: 14px;
      border-top: 1px solid #e5e7eb;
      text-align: center;
      font-size: 10px; color: #9CA3AF;
      line-height: 1.7;
    }

    /* Screen-only print button */
    .print-hint {
      margin: 20px 20px 0;
      padding: 10px 14px;
      background: #F0F9FF;
      border: 1px solid #BAE6FD;
      border-radius: 8px;
      font-size: 11px; color: #0369A1; text-align: center;
    }
    @media print {
      .print-hint { display: none; }
      .wrap { max-width: 100%; }
      .header { border-radius: 0; }
    }
  </style>
</head>
<body>
  <div class="wrap">

    <div class="header">
      <div class="brand-label">LaundryHub</div>
      <span class="receipt-icon">🧾</span>
      <div class="title">Cash on Delivery Receipt</div>
      <div class="order-pill">${displayId}</div>
      <div class="issued">${issuedLine}</div>
    </div>

    <div class="section">
      <div class="section-head">Customer Information</div>
      <table>
        ${buildRows(customerRows)}
      </table>

      <div class="section-head">Order Details</div>
      <table>
        ${buildRows(orderRows)}
      </table>
    </div>

    <div class="total-box">
      <div>
        <div class="total-label">Total Amount Paid</div>
        <div class="total-amount">${totalText}</div>
      </div>
      <div class="total-icon">💳</div>
    </div>

    <div class="cod-box">
      <div class="cod-circle">✓</div>
      <div>
        <div class="cod-title">Cash on Delivery (COD)</div>
        <div class="cod-sub">Payment is collected at the time of delivery or pickup by our laundry staff.</div>
      </div>
    </div>

    <div class="print-hint">
      💡 To save as PDF: In the print dialog, set <strong>Destination → Save as PDF</strong>, then click Save.
    </div>

    <div class="receipt-footer">
      © 2026 LaundryHub &nbsp;·&nbsp; Cash on Delivery Receipt<br>
      Keep this receipt for your records. Thank you for choosing LaundryHub!
    </div>

  </div>
</body>
</html>`;

  const win = window.open('', '_blank', 'width=680,height=860');
  if (!win) {
    showToast('Allow pop-ups to print/save this receipt.');
    return;
  }

  win.document.open();
  win.document.write(html);
  win.document.close();

  // Fire print() only after full load — works for both Print and Save as PDF
  win.onload = () => {
    win.focus();
    win.print();
  };
}

// ==========================================
// REPORTS DOWNLOAD
// ==========================================

function downloadCSVReport() {
  const filterVal = document.getElementById('report-filter')?.value || 'all';
  let orders = Object.values(state.bookings.byId || {});
  
  if (filterVal !== 'all') {
    orders = orders.filter(o => normalizeStatus(o.status) === filterVal);
  }

  if (!orders.length) {
    showToast('No orders available to export for the selected filter.');
    return;
  }

  const headers = ['Order ID', 'Customer', 'Service', 'Weight (kg)', 'Total Price', 'Status', 'Date'];
  const rows = orders.map(o => [
    formatOrderDisplayId(o),
    `"${escapeHtml(o.customer_name || 'N/A')}"`,
    `"${escapeHtml(o.service_type || 'N/A')}"`,
    o.weight_kg || 0,
    o.total_price || 0,
    normalizeStatus(o.status),
    formatDate(o.created_at)
  ]);

  const csvContent = [headers.join(','), ...rows.map(r => r.join(','))].join('\n');
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', `LaundryHub_Orders_Report_${new Date().toISOString().split('T')[0]}.csv`);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

function downloadPDFReport() {
  const filterVal = document.getElementById('report-filter')?.value || 'all';
  let orders = Object.values(state.bookings.byId || {});
  
  if (filterVal !== 'all') {
    orders = orders.filter(o => normalizeStatus(o.status) === filterVal);
  }

  if (!orders.length) {
    showToast('No orders available to export for the selected filter.');
    return;
  }

  const win = window.open('', '_blank', 'width=800,height=900');
  if (!win) {
    showToast('Please allow pop-ups to generate PDF report.');
    return;
  }

  const rowsHtml = orders.map(o => `
    <tr>
      <td>${formatOrderDisplayId(o)}</td>
      <td>${escapeHtml(o.customer_name || 'N/A')}</td>
      <td>${escapeHtml(o.service_type || 'N/A')}</td>
      <td>${o.weight_kg || 0}kg</td>
      <td>${formatCurrency(o.total_price || 0)}</td>
      <td><span style="text-transform:capitalize;">${normalizeStatus(o.status)}</span></td>
    </tr>
  `).join('');

  win.document.write(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>LaundryHub Monthly Report</title>
        <style>
          body { font-family: 'Segoe UI', Arial, sans-serif; color: #08213D; padding: 40px; }
          .header { text-align: center; margin-bottom: 40px; border-bottom: 2px solid #1565C0; padding-bottom: 20px; }
          .header h1 { margin: 0 0 10px 0; color: #1565C0; }
          table { width: 100%; border-collapse: collapse; margin-top: 20px; font-size: 12px; }
          th { background: #f1f5f9; text-align: left; padding: 10px; border-bottom: 2px solid #cbd5e1; }
          td { padding: 10px; border-bottom: 1px solid #e2e8f0; }
          @page { size: A4 portrait; margin: 20mm; }
          @media print { .hint { display: none; } }
        </style>
      </head>
      <body>
        <div class="hint" style="background:#e0f2fe; padding:10px; margin-bottom:20px; text-align:center; color:#0369a1; border-radius:6px; font-size:13px;">
          💡 To save as PDF: Choose "Save as PDF" in the print dialog.
        </div>
        <div class="header">
          <h1>LaundryHub Orders Report</h1>
          <p>Generated on ${new Date().toLocaleDateString()}</p>
        </div>
        <table>
          <thead>
            <tr>
              <th>Order ID</th>
              <th>Customer</th>
              <th>Service</th>
              <th>Weight</th>
              <th>Total</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            ${rowsHtml}
          </tbody>
        </table>
      </body>
    </html>
  `);

  win.document.close();
  win.onload = () => {
    win.focus();
    win.print();
  };
}

// Initialize the new report buttons
document.addEventListener('DOMContentLoaded', () => {
  const btnCsv = document.getElementById('btn-download-csv');
  const btnPdf = document.getElementById('btn-download-pdf');
  
  if (btnCsv) btnCsv.addEventListener('click', downloadCSVReport);
  if (btnPdf) btnPdf.addEventListener('click', downloadPDFReport);
});
