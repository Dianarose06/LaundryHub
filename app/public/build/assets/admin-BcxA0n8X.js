import"./app-UyRVujZY.js";const n={token:null,user:null,isLoginSubmitting:!1,isLogoutSubmitting:!1,view:"dashboard",bookings:{page:1,perPage:20,status:"all",steps:{},byId:{},activeOrderId:null},customers:{page:1,perPage:20,search:""},services:{editingId:null},customerOrders:{page:1,perPage:10,lastPage:1},currentCustomerId:null},o=(e,t=document)=>t.querySelector(e),j=(e,t=document)=>Array.from(t.querySelectorAll(e)),Se=`${window.LAUNDRYHUB_API_BASE_URL||"/api"}`.replace(/\/$/,"");function c(e,t){const s=typeof e=="string"?o(e):e;s&&(s.textContent=t)}function U(e){e&&e.classList.remove("hidden")}function J(e){e&&e.classList.add("hidden")}function h(e){const t=o("#toast");t&&(t.textContent=e,t.classList.add("show"),t.setAttribute("aria-hidden","false"),setTimeout(()=>{t.classList.remove("show"),t.setAttribute("aria-hidden","true")},3e3))}function w(e){return`PHP ${Number(e||0).toLocaleString("en-PH",{maximumFractionDigits:0})}`}function _(e){if(!e)return"---";const t=new Date(e);return Number.isNaN(t.getTime())?e:t.toLocaleDateString("en-PH",{month:"short",day:"numeric",year:"numeric"})}function I(e,t="---"){return e==null||e===""?t:e}function V(e){return`${e??""}`.replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;").replaceAll('"',"&quot;").replaceAll("'","&#039;")}function ue(e){return e?"Yes":"No"}function ee(e){return`${e||""}`.trim().toLowerCase()}function Z(e){return(e||"").toString().toLowerCase()}function ke(e){return(Z(e)||"pickup")==="delivery"?"Delivery":"Pickup"}function se(e){const t=e?.id??e?.order_id??"",s=String(t).replace(new RegExp("^#?LH-+"),"");return s?`#LH-${s.padStart(3,"0")}`:String(t||"---")}function Te(e){const t=e.order_id||e.id,s=Z(e.status),a=Le(t,s),i=_(e.pickup_date),r=_(e.delivery_date||e.pickup_date),d=ke(e.delivery_type),l=I(e.pickup_address),p=_(e.updated_at),u=["ongoing","ready","completed"].includes(s)?Ye(t,a):"",m=Ke(t,s);return`
    <div class="details-grid">
      <div>
        <div class="details-label">Pickup date</div>
        <div class="details-value">${i}</div>
      </div>
      <div>
        <div class="details-label">Delivery date</div>
        <div class="details-value">${r}</div>
      </div>
      <div>
        <div class="details-label">Delivery type</div>
        <div class="details-value">${d}</div>
      </div>
      <div>
        <div class="details-label">Pickup address</div>
        <div class="details-value">${l}</div>
      </div>
      <div>
        <div class="details-label">Created</div>
        <div class="details-value">${_(e.created_at)}</div>
      </div>
      <div>
        <div class="details-label">Updated</div>
        <div class="details-value">${p}</div>
      </div>
    </div>
    <div class="details-actions">
      ${u?`<div class="step-chips">${u}</div>`:"<div></div>"}
      <div class="action-buttons">${m||'<span class="text-xs text-muted">No actions</span>'}</div>
    </div>
  `}function De(e){return e==="ready"?2:e==="completed"?3:e==="ongoing"?0:null}function Me(e){return e===2?"ready":e===3?"completed":"ongoing"}function te(e){n.view=e,j(".view-section").forEach(t=>{t.classList.toggle("hidden",t.dataset.view!==e)}),j("[data-view]").forEach(t=>{t.classList.toggle("active",t.dataset.view===e)}),Re(e).catch(t=>{console.error("Failed to load view",t)})}function we(e,t){localStorage.setItem("lh_admin_token",e),localStorage.setItem("lh_admin_user",JSON.stringify(t)),n.token=e,n.user=t}function q(){localStorage.removeItem("lh_admin_token"),localStorage.removeItem("lh_admin_user"),n.token=null,n.user=null}function xe(){return window.location.pathname==="/admin"}function Ae(){return window.location.pathname.startsWith("/admin/dashboard")}function K(){if(_e(),!xe()){window.location.assign("/admin");return}U(o(".bg-aurora")),U(o("#login-view")),J(o("#app-view"))}function Ne(){if(!Ae()){window.location.assign("/admin/dashboard");return}if(J(o(".bg-aurora")),J(o("#login-view")),U(o("#app-view")),Fe(),n.user){const e=n.user.name?.trim()||"LaundryHub Admin",t="Admin",s=t.charAt(0).toUpperCase()||"A",a=n.user.email||"admin@laundryhub.com";c("#user-name",e),c("#user-email",n.user.email||""),c("#header-admin-name",t),c("#header-admin-avatar",s),c("#sidebar-admin-name",t),c("#sidebar-admin-email",a),c("#sidebar-admin-avatar",s)}}function Fe(){const e=o("#app-view");if(!e||e.classList.contains("hidden"))return;const t=[".sidebar",".mobile-topbar","#login-view",".drawer",".modal"];j("body *").forEach(a=>{if(!(a instanceof HTMLElement)||a.id==="app-view"||a.id==="login-view"||t.some(m=>a.closest(m)))return;const i=a.getBoundingClientRect();if(i.width<320||i.height<320)return;const r=window.getComputedStyle(a);if(!(["fixed","absolute"].includes(r.position)||r.pointerEvents==="none"||Number(r.opacity||"1")<.35))return;const l=`${a.className||""}`.toLowerCase(),p=`${a.id||""}`.toLowerCase();(l.includes("watermark")||l.includes("logo")||l.includes("aurora")||l.includes("bg-")||p.includes("watermark")||p.includes("logo")||r.zIndex==="0"&&r.pointerEvents==="none")&&(a.style.display="none")})}function pe(){o(".sidebar")?.classList.remove("open"),o("#sidebar-overlay")?.classList.remove("show"),o("#sidebar-toggle")?.setAttribute("aria-expanded","false")}function Pe(){const e=o(".sidebar"),t=o("#sidebar-overlay"),s=o("#sidebar-toggle");if(!e||!t||!s)return;const a=e.classList.toggle("open");t.classList.toggle("show",a),s.setAttribute("aria-expanded",a?"true":"false")}function ge(e){const t=o("#login-submit"),s=o("#login-submit .btn-spinner"),a=o("#login-submit .btn-label"),i=o("#login-email"),r=o("#login-password");t&&(t.disabled=e,t.classList.toggle("is-loading",e),t.setAttribute("aria-busy",e?"true":"false")),s&&s.classList.toggle("hidden",!e),a&&(a.textContent=e?"Signing in...":"Sign in"),i&&(i.disabled=e),r&&(r.disabled=e)}function ae(e){const t=o("#logout-modal-confirm"),s=o("#logout-modal-confirm .btn-spinner"),a=o("#logout-modal-confirm .btn-label"),i=o("#logout-modal-cancel");t&&(t.disabled=e,t.classList.toggle("is-loading",e),t.setAttribute("aria-busy",e?"true":"false")),s&&s.classList.toggle("hidden",!e),a&&(a.textContent=e?"Logging out...":"Yes"),i&&(i.disabled=e)}async function v(e,t={}){const s=new AbortController,a=Number.isFinite(t.timeoutMs)?t.timeoutMs:2e4,i=a>0?setTimeout(()=>s.abort(),a):null,r={method:t.method||"GET",headers:{Accept:"application/json",...t.headers},signal:s.signal};!t.skipAuth&&n.token&&(r.headers.Authorization=`Bearer ${n.token}`),t.body&&(r.headers["Content-Type"]="application/json",r.body=JSON.stringify(t.body));try{const d=await fetch(`${Se}${e}`,r);i&&clearTimeout(i);let l=null;try{l=await d.json()}catch{l=null}return(d.status===401||d.status===403)&&(q(),K(),h("Session expired. Please sign in again.")),{ok:d.ok,status:d.status,data:l}}catch(d){return i&&clearTimeout(i),d?.name==="AbortError"?(h("Request timed out. The server may still be starting up."),{ok:!1,status:408,data:{message:"Request timed out."}}):(h("Network error. Please try again."),{ok:!1,status:0,data:null})}}async function Oe(){const e=xe(),t=localStorage.getItem("lh_admin_token"),s=localStorage.getItem("lh_admin_user");if(!t||!s){q(),K();return}let a=null;try{a=JSON.parse(s)}catch{q(),K();return}if(!a||ee(a.role)!=="admin"){q(),K();return}if(e){window.location.assign("/admin/dashboard");return}n.token=t,n.user=a,Ne(),te("dashboard");const i=await v("/user");i.ok&&ee(i.data?.role)==="admin"&&we(t,i.data)}async function He(e){if(e.preventDefault(),n.isLoginSubmitting)return;const t=o("#login-email")?.value.trim()||"",s=o("#login-password")?.value||"",a=o("#login-error");J(a),n.isLoginSubmitting=!0,ge(!0);let i=!1,r;try{if(r=await v("/login",{method:"POST",body:{email:t,password:s},skipAuth:!0,timeoutMs:45e3}),!r.ok){c(a,r.data?.message||"Login failed."),U(a);return}const d=r.data?.user||r.data?.data?.user||null,l=`${r.data?.token||r.data?.access_token||r.data?.data?.token||r.data?.data?.access_token||""}`.trim(),p=ee(d?.role);if(!l){c(a,"Login failed. Missing access token."),U(a);return}if(p!=="admin"){c(a,"This account does not have admin access."),U(a);return}we(l,d),i=!0,window.location.assign("/admin/dashboard")}finally{n.isLoginSubmitting=!1,i||ge(!1)}}async function Ie(){Be()}function Be(){n.isLogoutSubmitting||(ae(!1),o("#logout-modal-overlay")?.classList.add("show"),o("#logout-modal")?.classList.remove("hidden"),o("#logout-modal")?.classList.add("show"))}function me(){n.isLogoutSubmitting||(ae(!1),o("#logout-modal-overlay")?.classList.remove("show"),o("#logout-modal")?.classList.remove("show"),o("#logout-modal")?.classList.add("hidden"))}async function ze(){if(!n.isLogoutSubmitting){n.isLogoutSubmitting=!0,ae(!0);try{n.token&&await v("/logout",{method:"POST"})}catch{}finally{q(),window.location.assign("/admin")}}}async function Re(e){e==="dashboard"?await Ue():e==="bookings"?await R():e==="customers"?await Y():e==="analytics"?await Ze():e==="services"&&await ne()}async function Ue(){c("#stat-total-bookings","--"),c("#stat-pending","--"),c("#stat-revenue","--"),c("#stat-customers","--");const[e,t,s]=await Promise.all([v("/admin/stats"),v("/admin/orders/recent"),v("/admin/top-customers")]);if(e.ok&&e.data){const a=e.data.total_bookings??0,i=e.data.pending_count??0,r=e.data.revenue_today??0,d=e.data.customer_count??0;c("#stat-total-bookings",a),c("#stat-pending",i),c("#stat-revenue",w(r)),c("#stat-customers",d);const l=o("#stat-badge-total");l&&(l.className="stat-badge green",l.textContent="All time");const p=o("#stat-badge-pending");p&&(i>0?(p.className="stat-badge amber",p.textContent="Needs action"):(p.className="stat-badge green",p.textContent="All clear"));const u=o("#stat-badge-revenue");u&&(r>0?(u.className="stat-badge green",u.textContent="Earning today"):(u.className="stat-badge red",u.textContent="No revenue yet"));const m=o("#stat-badge-customers");m&&(m.className="stat-badge green",m.textContent="Growing")}je(t.ok?t.data?.data||[]:[]),oe(s.ok?s.data?.data||[]:[],"#top-customers-body")}function je(e){const t=o("#recent-orders-body");if(t){if(t.innerHTML="",!e.length){t.innerHTML='<tr><td colspan="5">No recent orders.</td></tr>';return}e.forEach(s=>{const a=document.createElement("tr"),i=(s.status||"").toString().toLowerCase();a.innerHTML=`
      <td><span class="order-id">${s.id||""}</span></td>
      <td>${s.customer_name||"Unknown"}</td>
      <td>${s.service_type||"Service"}</td>
      <td>${w(s.total_price||0)}</td>
      <td><span class="status-pill" data-status="${i}">${s.status||"Pending"}</span></td>
    `,t.appendChild(a)})}}const fe=[{bg:"#EDE9FE",color:"#5B21B6"},{bg:"#CCFBF1",color:"#0F766E"},{bg:"#DBEAFE",color:"#1D4ED8"},{bg:"#FFE4E6",color:"#BE123C"},{bg:"#FEF3C7",color:"#92400E"},{bg:"#D1FAE5",color:"#065F46"}],Ve=["gold","silver","bronze","plain"],qe=["1","2","3","4"];function oe(e,t){const s=typeof t=="string"?o(t):t;if(s){if(s.innerHTML="",!e.length){s.innerHTML='<div style="font-size:13px;color:var(--color-text-secondary)">No data yet.</div>';return}e.forEach((a,i)=>{const r=(a.name||"C").split(" ").map(m=>m[0]).join("").toUpperCase().slice(0,2),d=fe[i%fe.length],l=Ve[Math.min(i,3)],p=qe[Math.min(i,3)],u=document.createElement("div");u.className="top-customer-row",u.innerHTML=`
      <span class="medal-dot ${l}">${p}</span>
      <span class="customer-avatar" style="background:${d.bg};color:${d.color}">${r}</span>
      <div class="top-customer-info">
        <div class="top-customer-name">${a.name||"Customer"}</div>
        <div class="top-customer-meta">${a.orders||0} orders</div>
      </div>
      <div class="top-customer-spend">${a.spend||""}</div>
    `,s.appendChild(u)})}}function G(e){j("#booking-status-chips [data-status]").forEach(t=>{t.classList.toggle("active",t.dataset.status===e)})}async function We(){const e=await v("/admin/booking-summaries");if(!e.ok)return;const t=e.data?.data||{},s=t.by_status||{},a=t.total??0;j("[data-status-count]").forEach(i=>{const r=i.dataset.statusCount,d=r==="all"?a:s[r]??0;c(i,d)})}function Le(e,t){const s=De(t);return t==="ready"||t==="completed"?(n.bookings.steps[e]=s,s):n.bookings.steps[e]!==void 0?n.bookings.steps[e]:s!==null?(n.bookings.steps[e]=s,s):null}function Ye(e,t){return t===null?"":["Washing","Drying","Ready","Done"].map((a,i)=>`<button class="step-chip ${i===t?"active":""}" data-booking-step="${i}" data-order-id="${e}" type="button">${a}</button>`).join("")}function Ke(e,t){const s=[];return t==="pending"&&(s.push(`<button class="button-outline btn-sm btn-success" data-booking-action="accept" data-order-id="${e}" type="button">Accept</button>`),s.push(`<button class="button-outline btn-sm btn-danger" data-booking-action="decline" data-order-id="${e}" type="button">Decline</button>`)),(t==="ongoing"||t==="ready")&&s.push(`<button class="button-outline btn-sm btn-success" data-booking-action="complete" data-order-id="${e}" type="button">Complete</button>`),s.join("")}function $e(e){const t=String(e),s=n.bookings.byId[t];if(!s)return;n.bookings.activeOrderId=t;const a=o("#booking-modal"),i=o("#booking-modal-overlay"),r=o("#booking-modal-body"),d=o("#booking-modal-title"),l=o("#booking-modal-subtitle"),p=se(s),u=Z(s.status)||"pending";d&&(d.textContent="Booking details"),l&&(l.textContent=`${p} · ${u}`),r&&(r.innerHTML=Te(s)),i&&i.classList.add("show"),a&&(a.classList.add("show"),a.classList.remove("hidden"))}function _e(){n.bookings.activeOrderId=null,o("#booking-modal-overlay")?.classList.remove("show");const e=o("#booking-modal");e&&(e.classList.remove("show"),e.classList.add("hidden"))}function be(e){const t=e.dataset.orderId,s=e.dataset.bookingAction;s==="accept"?(n.bookings.steps[t]=0,W(t,"ongoing")):s==="decline"?W(t,"cancelled"):s==="complete"&&(n.bookings.steps[t]=3,W(t,"completed"))}function ve(e){const t=e.dataset.orderId,s=Number(e.dataset.bookingStep);Number.isNaN(s)||(n.bookings.steps[t]=s,W(t,Me(s)))}async function R(){const e=We(),t=o("#bookings-filter");t&&(t.value=n.bookings.status);const s=new URLSearchParams({page:n.bookings.page.toString(),per_page:n.bookings.perPage.toString()});n.bookings.status&&n.bookings.status!=="all"&&s.set("status",n.bookings.status);const a=await v(`/admin/orders?${s.toString()}`),i=o("#bookings-table-body");if(!i)return;if(i.innerHTML="",!a.ok){i.innerHTML='<tr><td colspan="8">Unable to load bookings.</td></tr>';return}const r=a.data?.data||[],d=a.data?.pagination||{};if(n.bookings.byId={},!r.length){i.innerHTML='<tr><td colspan="8">No bookings found.</td></tr>',await e,G(n.bookings.status);return}r.forEach(g=>{const x=g.order_id||g.id,S=String(x);n.bookings.byId[S]=g;const L=Z(g.status);Le(x,L);const T=document.createElement("tr"),P=(g.customer_name||"Customer").split(" ").map(A=>A[0]).join("").substring(0,2).toUpperCase(),$=_(g.created_at),E=se(g),D=[{bg:"#EEEDFE",color:"#3C3489"},{bg:"#E1F5EE",color:"#085041"},{bg:"#E6F1FB",color:"#0C447C"}],M=D[(g.customer_id||0)%D.length];T.innerHTML=`
      <td><span class="order-id">${E}</span></td>
      <td>
        <div class="order-customer-cell">
          <span class="order-customer-avatar" style="background:${M.bg};color:${M.color}">${P}</span>
          <span class="order-customer-name">${g.customer_name||"Unknown"}</span>
        </div>
      </td>
      <td>${g.service_type||"Service"}</td>
      <td>${g.weight_kg||0} kg</td>
      <td>${w(g.total_price||0)}</td>
      <td>
        <span class="status-pill" data-status="${L}">
          <span class="status-dot"></span>
          ${L}
        </span>
      </td>
      <td><span class="order-created-date">${$}</span></td>
      <td>
        <div style="display:flex; gap:6px; align-items:center;">
          <button class="btn-action-pill btn-action-details" data-booking-toggle="${x}" type="button">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            Details
          </button>
          <button class="btn-action-pill btn-action-receipt" data-cod-receipt-id="${x}" type="button">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
            Receipt
          </button>
        </div>
      </td>
    `,i.appendChild(T)});const l=d.total||r.length;c("#bookings-footer-info",`Showing ${r.length} of ${l} orders — Page ${d.current_page||1} of ${d.last_page||1}`);const p=o("#bookings-prev"),u=o("#bookings-next"),m=o("#bookings-current-page");p&&(p.disabled=(d.current_page||1)<=1),u&&(u.disabled=(d.current_page||1)>=(d.last_page||1)),m&&(m.textContent=d.current_page||1),await e,G(n.bookings.status)}async function W(e,t){const s=String(e),a=await v(`/admin/orders/${e}/status`,{method:"PATCH",body:{status:t}});if(!a.ok){h("Unable to update status.");return}h("Order status updated.");const i=a.data?.data;await R(),i&&(n.bookings.byId[s]=i),n.bookings.activeOrderId===s&&$e(e)}async function Y(){const e=new URLSearchParams({page:n.customers.page.toString(),per_page:n.customers.perPage.toString()});n.customers.search&&e.set("search",n.customers.search);const t=await v(`/admin/customers?${e.toString()}`),s=o("#customers-table-body");if(!s)return;if(s.innerHTML="",!t.ok){s.innerHTML='<tr><td colspan="6">Unable to load customers.</td></tr>';return}const a=t.data?.data||[],i=t.data?.pagination||{};a.length||(s.innerHTML='<tr><td colspan="6">No customers found.</td></tr>'),a.forEach(l=>{const p=document.createElement("tr");p.innerHTML=`
      <td>
        <div class="font-semibold">${l.name||"Customer"}</div>
        <div class="text-xs text-slate-500">${l.email||""}</div>
      </td>
      <td>${l.phone||"---"}</td>
      <td>${l.orders_count||0}</td>
      <td>${w(l.total_spent||0)}</td>
      <td>${l.loyalty_points||0}</td>
      <td>
        <button class="button-outline" data-customer-id="${l.id}">View</button>
      </td>
    `,s.appendChild(p)}),c("#customers-page-info",`Page ${i.current_page||1} of ${i.last_page||1}`);const r=o("#customers-prev"),d=o("#customers-next");r&&(r.disabled=(i.current_page||1)<=1),d&&(d.disabled=(i.current_page||1)>=(i.last_page||1))}async function Je(e){n.currentCustomerId=e,o("#customer-drawer")?.classList.add("open"),o("#drawer-overlay")?.classList.add("show"),c("#customer-drawer-title","Loading...");const t=await v(`/admin/customers/${e}`);if(!t.ok){h("Unable to load customer.");return}const s=t.data?.data||{};c("#customer-drawer-title",s.name||"Customer"),o("#customer-name").value=s.name||"",o("#customer-email").value=s.email||"",o("#customer-phone").value=s.phone||"",o("#customer-address").value=s.address||"",o("#customer-city").value=s.city||"",o("#customer-zip").value=s.zip_code||"",o("#customer-country").value=s.country||"",o("#customer-notifications").checked=s.notifications_enabled!==!1,c("#customer-loyalty",s.loyalty_points||0),c("#customer-orders-count",s.orders_count||0),c("#customer-total-spent",w(s.total_spent||0)),c("#customer-dob",I(_(s.date_of_birth))),c("#customer-gender",I(s.gender)),c("#customer-language",I(s.preferred_language)),c("#customer-email-verified",ue(!!s.email_verified_at)),c("#customer-profile-completed",ue(!!s.profile_completed_at)),c("#customer-member-since",I(_(s.created_at))),c("#customer-last-login",I(_(s.last_login_at))),c("#customer-bio",I(s.bio)),n.customerOrders.page=1,n.customerOrders.lastPage=1,await Ee(!0)}function ye(){o("#customer-drawer")?.classList.remove("open"),o("#drawer-overlay")?.classList.remove("show"),n.currentCustomerId=null}async function Ge(){if(!n.currentCustomerId)return;const e={name:o("#customer-name").value.trim(),phone:o("#customer-phone").value.trim()||null,address:o("#customer-address").value.trim()||null,city:o("#customer-city").value.trim()||null,zip_code:o("#customer-zip").value.trim()||null,country:o("#customer-country").value.trim()||null,notifications_enabled:o("#customer-notifications").checked};if(!(await v(`/admin/customers/${n.currentCustomerId}`,{method:"PUT",body:e})).ok){h("Unable to update customer.");return}h("Customer updated."),await Y()}async function Ee(e=!1){if(!n.currentCustomerId)return;e&&(n.customerOrders.page=1);const t=new URLSearchParams({page:n.customerOrders.page.toString(),per_page:n.customerOrders.perPage.toString()}),s=await v(`/admin/customers/${n.currentCustomerId}/orders?${t.toString()}`),a=o("#customer-orders-body");if(!a)return;if(!s.ok){e&&(a.innerHTML='<tr><td colspan="5">Unable to load orders.</td></tr>');return}const i=s.data?.data||[],r=s.data?.pagination||{};e&&(a.innerHTML=""),!i.length&&e&&(a.innerHTML='<tr><td colspan="5">No orders yet.</td></tr>'),i.forEach(u=>{const m=document.createElement("tr");m.innerHTML=`
      <td>${u.id||""}</td>
      <td>${u.service_type||""}</td>
      <td>${u.weight_kg||0} kg</td>
      <td>${w(u.total_price||0)}</td>
      <td>${u.status||""}</td>
    `,a.appendChild(m)}),n.customerOrders.lastPage=r.last_page||1;const d=r.current_page||n.customerOrders.page;c("#customer-orders-page-info",`Page ${d} of ${n.customerOrders.lastPage}`);const l=Number.isFinite(r.total)?r.total:i.length;c("#customer-orders-title-count",`(${l})`);const p=o("#customer-orders-load");if(p){const u=d>=n.customerOrders.lastPage;p.disabled=u,p.classList.toggle("hidden",u||l===0)}}async function Ze(){const e=await v("/admin/analytics");if(!e.ok){h("Unable to load analytics.");return}const t=e.data||{},s=Number(t.monthly_revenue||0),a=Number(t.total_orders_this_month||0),i=Number(t.completed_orders_this_month||0),r=Number(t.cancelled_orders_this_month||0),d=Number(t.new_customers_this_month||0),l=Number(t.total_customers||0),p=Number(t.completion_rate||0),u=t.top_service||null,m=Array.isArray(t.top_customers)?t.top_customers:[],g=m[0]||null;c("#analytics-month",t.month_label||""),c("#analytics-monthly-revenue",w(s)),c("#analytics-monthly-card",w(s)),c("#analytics-completion-rate",`${p}%`),c("#analytics-monthly-orders",a),c("#analytics-new-customers",d),c("#analytics-total-customers",`${l} total customers`),c("#analytics-completed-orders",i),c("#analytics-cancelled-orders",`${r} cancelled`),c("#analytics-top-service",u?.name||"No service data yet"),c("#analytics-top-service-meta",u?`${u.orders||0} orders`:"No completed order mix yet"),c("#analytics-top-customer",g?.name||"No customer data yet"),c("#analytics-top-customer-meta",g?`${g.orders||0} orders · ${g.spend_label||w(g.spend||0)}`:"No customer orders yet"),c("#analytics-order-health",`${p}% completion`);const x=t.weekly_revenue||[],S=Math.max(1,...x.map(b=>Number(b||0))),L=["Mon","Tue","Wed","Thu","Fri","Sat","Sun"],T=o("#weekly-bars");T.innerHTML="",x.forEach((b,N)=>{const k=Math.round(Number(b||0)/S*100),C=document.createElement("div");C.className="weekly-bar",C.innerHTML=`
      <div class="weekly-bar-value">${w(Number(b||0))}</div>
      <div class="weekly-bar-track" title="${w(Number(b||0))}">
        <div class="weekly-bar-fill" style="height:${k}%;"></div>
      </div>
      <div class="weekly-bar-label">${L[N]||""}</div>
    `,T.appendChild(C)});const P=t.service_breakdown||[],$=o("#service-breakdown-body"),E=o("#service-breakdown-donut"),D=o("#service-breakdown-total");$&&($.innerHTML="");const M=["#3B82F6","#34D399","#F59E0B","#EC4899","#A78BFA","#22D3EE"];let A=0,O=0;const B=[];if(!P.length)$&&($.innerHTML='<div class="analytics-empty">No service data yet.</div>'),E&&(E.style.background="conic-gradient(rgba(148, 163, 184, 0.2) 0% 100%)"),D&&c("#service-breakdown-total","0%");else if(P.forEach((b,N)=>{const k=Math.max(0,Math.min(100,Number(b.pct||0))),C=M[N%M.length];if(k>0&&B.push(`${C} ${A}% ${A+k}%`),A+=k,O+=k,$){const z=document.createElement("div");z.className="breakdown-legend-row",z.innerHTML=`
          <span class="breakdown-legend-swatch" style="background:${C};"></span>
          <div class="breakdown-legend-copy">
            <div class="breakdown-legend-name">${V(b.name||"Service")}</div>
            <div class="breakdown-legend-meta">${k}% &middot; ${b.count||0} orders</div>
          </div>
        `,$.appendChild(z)}}),E){const b=Math.min(100,Math.round(O));O<100&&B.push(`rgba(148, 163, 184, 0.2) ${O}% 100%`),E.style.background=`conic-gradient(${B.join(", ")})`,D&&c("#service-breakdown-total",`${b}%`)}const H=o("#analytics-top-customers-list");H&&(H.innerHTML="",m.length?m.forEach((b,N)=>{const k=document.createElement("div");k.className="analytics-customer-row",k.innerHTML=`
          <span class="analytics-rank">${N+1}</span>
          <div class="analytics-customer-copy">
            <strong>${V(b.name||"Customer")}</strong>
            <span>${b.orders||0} orders</span>
          </div>
          <div class="analytics-customer-spend">${b.spend_label||w(b.spend||0)}</div>
        `,H.appendChild(k)}):H.innerHTML='<div class="analytics-empty">No customer spend data yet.</div>')}async function ne(){const[e,t]=await Promise.all([v("/admin/services"),v("/admin/top-customers")]),s=o("#services-table-body");if(!s)return;if(s.innerHTML="",!e.ok){s.innerHTML='<tr><td colspan="6">Unable to load services.</td></tr>',oe(t.ok?t.data?.data||[]:[],"#services-top-customers-body");return}const a=e.data?.data||[];a.length||(s.innerHTML='<tr><td colspan="6">No services found.</td></tr>'),a.forEach(i=>{const r=document.createElement("tr");r.innerHTML=`
      <td>
        <div class="font-semibold">${i.name||"Service"}</div>
        <div class="text-xs text-slate-500">${i.description||""}</div>
      </td>
      <td>${w(i.price_per_kg||0)}</td>
      <td>${i.category||"---"}</td>
      <td>${i.is_active?"Active":"Inactive"}</td>
      <td class="space-x-2">
        <button class="button-outline" data-edit-service="${i.id}">Edit</button>
        <button class="button-outline" data-delete-service="${i.id}">Delete</button>
      </td>
    `,s.appendChild(r)}),oe(t.ok?t.data?.data||[]:[],"#services-top-customers-body")}async function Qe(){const e={name:o("#service-name").value.trim(),description:o("#service-description").value.trim()||null,price_per_kg:Number(o("#service-price").value||0),category:o("#service-category").value.trim()||null,image_url:o("#service-image").value.trim()||null,is_active:o("#service-active").checked},t=n.services.editingId;if(!(await v(`/admin/services${t?`/${t}`:""}`,{method:t?"PUT":"POST",body:e})).ok){h("Unable to save service.");return}h(t?"Service updated.":"Service created."),Ce(),await ne()}function Ce(){n.services.editingId=null,c("#service-form-title","Create service"),o("#service-name").value="",o("#service-description").value="",o("#service-price").value="",o("#service-category").value="",o("#service-image").value="",o("#service-active").checked=!0}async function Xe(e){const t=await v("/admin/services");if(!t.ok)return;const a=(t.data?.data||[]).find(i=>i.id===Number(e));a&&(n.services.editingId=a.id,c("#service-form-title","Update service"),o("#service-name").value=a.name||"",o("#service-description").value=a.description||"",o("#service-price").value=a.price_per_kg||"",o("#service-category").value=a.category||"",o("#service-image").value=a.image_url||"",o("#service-active").checked=a.is_active!==!1)}async function et(e){if(!window.confirm("Delete this service?"))return;if(!(await v(`/admin/services/${e}`,{method:"DELETE"})).ok){h("Unable to delete service.");return}h("Service deleted."),await ne()}function he(e,t,s){e.type=s?"text":"password",t.setAttribute("aria-pressed",s?"true":"false"),t.setAttribute("aria-label",s?"Hide password":"Show password"),t.innerHTML=s?'<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>':'<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>'}function tt(){const e=o("#login-form");e&&e.addEventListener("submit",He);const t=o("#toggle-password"),s=o("#login-password");t&&s&&(he(s,t,!1),t.addEventListener("click",()=>{const f=s.type==="password";he(s,t,f)}));const a=o("#logout-button");a&&a.addEventListener("click",Ie);const i=o("#logout-modal-cancel");i&&i.addEventListener("click",me);const r=o("#logout-modal-confirm");r&&r.addEventListener("click",ze);const d=o("#logout-modal-overlay");d&&d.addEventListener("click",me),j("[data-view]").forEach(f=>{f.addEventListener("click",()=>{te(f.dataset.view),pe()})});const l=o("#bookings-filter");l&&l.addEventListener("change",f=>{n.bookings.status=f.target.value,n.bookings.page=1,G(n.bookings.status),R()});const p=o("#booking-status-chips");p&&p.addEventListener("click",f=>{const y=f.target.closest("[data-status]");y&&(n.bookings.status=y.dataset.status,n.bookings.page=1,G(n.bookings.status),l&&(l.value=n.bookings.status),R())});const u=o("#bookings-prev");u&&u.addEventListener("click",()=>{n.bookings.page=Math.max(1,n.bookings.page-1),R()});const m=o("#bookings-next");m&&m.addEventListener("click",()=>{n.bookings.page+=1,R()});const g=o("#bookings-table-body");g&&(g.addEventListener("change",f=>{const y=f.target.closest("select[data-order-id]");y&&W(y.dataset.orderId,y.value)}),g.addEventListener("click",f=>{const y=f.target.closest("[data-cod-receipt-id]");if(y){const Q=y.dataset.codReceiptId,le=n.bookings.byId[String(Q)];le?ot(le):h("Receipt data unavailable. Please refresh.");return}const F=f.target.closest("[data-booking-toggle]");if(F){const Q=F.dataset.bookingToggle;$e(Q);return}const ce=f.target.closest("[data-booking-action]");if(ce){be(ce);return}const de=f.target.closest("[data-booking-step]");de&&ve(de)}));const x=o("#booking-modal-close");x&&x.addEventListener("click",_e);const S=o("#booking-modal");S&&S.addEventListener("click",f=>{const y=f.target.closest("[data-booking-action]");if(y){be(y);return}const F=f.target.closest("[data-booking-step]");F&&ve(F)});const L=o("#customers-search-button");L&&L.addEventListener("click",()=>{n.customers.search=o("#customers-search-input").value.trim(),n.customers.page=1,Y()});const T=o("#customers-prev");T&&T.addEventListener("click",()=>{n.customers.page=Math.max(1,n.customers.page-1),Y()});const P=o("#customers-next");P&&P.addEventListener("click",()=>{n.customers.page+=1,Y()});const $=o("#customers-table-body");$&&$.addEventListener("click",f=>{const y=f.target.closest("[data-customer-id]");y&&Je(y.dataset.customerId)});const E=o("#customer-drawer-close");E&&E.addEventListener("click",ye);const D=o("#drawer-overlay");D&&D.addEventListener("click",ye);const M=o("#customer-save");M&&M.addEventListener("click",Ge);const A=o("#customer-orders-load");A&&A.addEventListener("click",()=>{n.customerOrders.page>=n.customerOrders.lastPage||(n.customerOrders.page+=1,Ee())});const O=o("#service-save");O&&O.addEventListener("click",Qe);const B=o("#service-clear");B&&B.addEventListener("click",Ce);const H=o("#services-table-body");H&&H.addEventListener("click",f=>{const y=f.target.closest("[data-edit-service]");if(y){Xe(y.dataset.editService);return}const F=f.target.closest("[data-delete-service]");F&&et(F.dataset.deleteService)});const b=o("#recent-orders-view-all");b&&b.addEventListener("click",()=>te("bookings"));const N=o("#sidebar-toggle");N&&N.addEventListener("click",Pe);const k=o("#sidebar-overlay");k&&k.addEventListener("click",pe);const C=o("#cod-receipt-close");C&&C.addEventListener("click",X);const z=o("#cod-receipt-cancel");z&&z.addEventListener("click",X);const ie=o("#cod-receipt-print");ie&&ie.addEventListener("click",st);const re=o("#cod-receipt-overlay");re&&re.addEventListener("click",X)}window.addEventListener("DOMContentLoaded",()=>{tt(),Oe()});function ot(e){const t=o("#cod-receipt-modal"),s=o("#cod-receipt-overlay"),a=o("#cod-receipt-body");if(!t||!s||!a)return;const i=se(e),r=ke(e.delivery_type),d=_(e.pickup_date),l=_(e.delivery_date),p=_(e.created_at),u=w(e.total_price||0),m=new Date().toLocaleDateString("en-PH",{month:"short",day:"numeric",year:"numeric"}),g=(x,S,L="")=>`
    <tr>
      <td style="padding:9px 12px; color:#58708D; font-size:12px; font-weight:500; width:42%; white-space:nowrap; vertical-align:middle;">
        ${L?`<span style="margin-right:5px; opacity:0.7;">${L}</span>`:""}${x}
      </td>
      <td style="padding:9px 12px; color:#08213D; font-size:12.5px; font-weight:600; vertical-align:middle;">${S}</td>
    </tr>`;a.innerHTML=`
    <div id="cod-receipt-print-area" style="font-family:'Segoe UI',Arial,sans-serif; color:#08213D; background:#fff;">

      <!-- Branded Header -->
      <div style="background:linear-gradient(135deg,#1565C0 0%,#0D47A1 100%); padding:22px 24px 20px; text-align:center; position:relative; overflow:hidden;">
        <div style="position:absolute;top:-18px;right:-18px;width:90px;height:90px;border-radius:50%;background:rgba(255,255,255,0.07);"></div>
        <div style="position:absolute;bottom:-24px;left:-12px;width:70px;height:70px;border-radius:50%;background:rgba(255,255,255,0.05);"></div>
        <div style="font-size:10px; font-weight:800; letter-spacing:0.22em; text-transform:uppercase; color:rgba(255,255,255,0.65); margin-bottom:6px;">LaundryHub</div>
        <div style="font-size:24px; font-weight:800; color:#fff; letter-spacing:-0.5px; margin-bottom:4px;">Cash on Delivery Receipt</div>
        <div style="display:inline-block; background:rgba(255,255,255,0.15); border-radius:20px; padding:3px 14px; font-size:12px; font-weight:700; color:#fff; letter-spacing:0.05em;">${i}</div>
        <div style="margin-top:6px; font-size:11px; color:rgba(255,255,255,0.55);">Issued: ${m}</div>
      </div>

      <!-- Detail Rows -->
      <div style="padding:4px 0;">
        <table style="width:100%; border-collapse:collapse;">
          <tbody>
            <tr style="background:#F8FBFF;">
              <td colspan="2" style="padding:7px 12px; font-size:10px; font-weight:800; letter-spacing:0.12em; text-transform:uppercase; color:#58708D;">Customer Info</td>
            </tr>
            ${g("Customer",V(e.customer_name||"N/A"),"👤")}
            ${g("Address",V(e.pickup_address||"N/A"),"📍")}
            <tr style="background:#F8FBFF;">
              <td colspan="2" style="padding:7px 12px; font-size:10px; font-weight:800; letter-spacing:0.12em; text-transform:uppercase; color:#58708D;">Order Details</td>
            </tr>
            ${g("Service",V(e.service_type||"---"),"🧺")}
            ${g("Weight",`${e.weight_kg||0} kg`,"⚖️")}
            ${g("Fulfillment",r,"🚚")}
            ${g("Pickup Date",d,"📅")}
            ${g("Delivery Date",l,"📅")}
            ${g("Order Date",p,"🗓️")}
          </tbody>
        </table>
      </div>

      <!-- Total Banner -->
      <div style="margin:0 16px 16px; background:linear-gradient(135deg,#EEF4FF 0%,#E8F0FE 100%); border:1px solid rgba(21,101,192,0.18); border-radius:10px; padding:16px 20px; display:flex; align-items:center; justify-content:space-between;">
        <div>
          <div style="font-size:10px; font-weight:700; letter-spacing:0.10em; text-transform:uppercase; color:#58708D; margin-bottom:2px;">Total Amount Due</div>
          <div style="font-size:26px; font-weight:800; color:#1565C0; letter-spacing:-0.5px;">${u}</div>
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
  `,t.classList.remove("hidden"),t.classList.add("show"),s.classList.add("show")}function X(){const e=o("#cod-receipt-modal"),t=o("#cod-receipt-overlay");e&&(e.classList.remove("show"),e.classList.add("hidden")),t&&t.classList.remove("show")}function st(){const e=o("#cod-receipt-print-area");if(!e)return;const t=window.open("","_blank","width=620,height=800");if(!t){h("Please allow pop-ups to print.");return}t.document.write(`
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <title>COD Receipt</title>
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }
          body {
            font-family: 'Segoe UI', Arial, sans-serif;
            color: #08213D;
            background: #fff;
            padding: 0;
          }
          .receipt-wrap { max-width: 480px; margin: 0 auto; padding-bottom: 24px; }
          .receipt-header {
            background: linear-gradient(135deg,#1565C0,#0D47A1);
            padding: 24px; text-align: center; color: #fff;
          }
          .receipt-header .brand { font-size: 10px; letter-spacing: 0.2em; text-transform: uppercase; opacity: 0.65; margin-bottom: 6px; }
          .receipt-header .title { font-size: 22px; font-weight: 800; letter-spacing: -0.5px; margin-bottom: 6px; }
          .receipt-header .order-id { display: inline-block; background: rgba(255,255,255,0.15); border-radius: 20px; padding: 2px 14px; font-size: 12px; font-weight: 700; }
          .receipt-header .date { margin-top: 5px; font-size: 11px; opacity: 0.55; }
          table { width: 100%; border-collapse: collapse; }
          td { padding: 9px 16px; font-size: 13px; vertical-align: middle; }
          .section-head td { padding: 7px 16px; font-size: 10px; font-weight: 800; letter-spacing: 0.1em; text-transform: uppercase; color: #58708D; background: #F8FBFF; }
          .label-col { color: #58708D; font-weight: 500; width: 42%; }
          .value-col { color: #08213D; font-weight: 600; }
          .total-box { margin: 16px; background: linear-gradient(135deg,#EEF4FF,#E8F0FE); border: 1px solid rgba(21,101,192,0.18); border-radius: 10px; padding: 16px 20px; display: flex; align-items: center; justify-content: space-between; }
          .total-label { font-size: 10px; font-weight: 700; letter-spacing: 0.1em; text-transform: uppercase; color: #58708D; margin-bottom: 3px; }
          .total-amount { font-size: 26px; font-weight: 800; color: #1565C0; }
          .cod-box { margin: 0 16px 20px; background: linear-gradient(135deg,#E8F5E9,#F1F8E9); border: 1px solid rgba(46,125,50,0.20); border-radius: 10px; padding: 14px 16px; display: flex; align-items: center; gap: 12px; }
          .cod-icon { width: 36px; height: 36px; border-radius: 50%; background: #2E7D32; color: #fff; font-size: 18px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
          .cod-title { font-size: 13px; font-weight: 700; color: #1B5E20; margin-bottom: 2px; }
          .cod-sub { font-size: 11px; color: #388E3C; line-height: 1.4; }
          .footer { text-align: center; font-size: 10px; color: #9CA3AF; margin-top: 20px; padding-top: 12px; border-top: 1px solid #e5e7eb; }
          @media print {
            body { print-color-adjust: exact; -webkit-print-color-adjust: exact; }
          }
        </style>
      </head>
      <body>
        <div class="receipt-wrap">
          ${e.innerHTML}
          <div class="footer">© 2026 LaundryHub · Cash on Delivery Receipt · Keep this for your records.</div>
        </div>
      </body>
    </html>
  `),t.document.close(),t.focus(),setTimeout(()=>t.print(),400)}
