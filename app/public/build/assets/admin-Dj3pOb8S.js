import"./app-UyRVujZY.js";const n={token:null,user:null,isLoginSubmitting:!1,isLogoutSubmitting:!1,view:"dashboard",bookings:{page:1,perPage:20,status:"all",steps:{},byId:{},activeOrderId:null},customers:{page:1,perPage:20,search:""},services:{editingId:null},customerOrders:{page:1,perPage:10,lastPage:1},currentCustomerId:null},o=(t,e=document)=>e.querySelector(t),j=(t,e=document)=>Array.from(e.querySelectorAll(t)),q=`${window.LAUNDRYHUB_API_BASE_URL||"/api"}`.replace(/\/$/,""),Dt=q.startsWith("http")&&q.includes(window.location.host)?q.substring(q.indexOf("/api")):q;function d(t,e){const s=typeof t=="string"?o(t):t;s&&(s.textContent=e)}function U(t){t&&t.classList.remove("hidden")}function G(t){t&&t.classList.add("hidden")}function x(t){const e=o("#toast");e&&(e.textContent=t,e.classList.add("show"),e.setAttribute("aria-hidden","false"),setTimeout(()=>{e.classList.remove("show"),e.setAttribute("aria-hidden","true")},3e3))}function _(t){return`PHP ${Number(t||0).toLocaleString("en-PH",{maximumFractionDigits:0})}`}function S(t){if(!t)return"---";const e=new Date(t);return Number.isNaN(e.getTime())?t:e.toLocaleDateString("en-PH",{month:"short",day:"numeric",year:"numeric"})}function I(t,e="---"){return t==null||t===""?e:t}function V(t){return`${t??""}`.replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;").replaceAll('"',"&quot;").replaceAll("'","&#039;")}function pt(t){return t?"Yes":"No"}function et(t){return`${t||""}`.trim().toLowerCase()}function Q(t){return(t||"").toString().toLowerCase()}function wt(t){return(Q(t)||"pickup")==="delivery"?"Delivery":"Pickup"}function at(t){const e=t?.id??t?.order_id??"",s=String(e).replace(new RegExp("^#?LH-+"),"");return s?`#LH-${s.padStart(3,"0")}`:String(e||"---")}function Tt(t){const e=t.order_id||t.id,s=Q(t.status),a=$t(e,s),i=S(t.pickup_date),r=S(t.delivery_date||t.pickup_date),l=wt(t.delivery_type),c=I(t.pickup_address),p=S(t.updated_at),u=["ongoing","ready","completed"].includes(s)?Kt(e,a):"",m=Jt(e,s);return`
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
        <div class="details-value">${l}</div>
      </div>
      <div>
        <div class="details-label">Pickup address</div>
        <div class="details-value">${c}</div>
      </div>
      <div>
        <div class="details-label">Created</div>
        <div class="details-value">${S(t.created_at)}</div>
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
  `}function At(t){return t==="ready"?2:t==="completed"?3:t==="ongoing"?0:null}function Mt(t){return t===2?"ready":t===3?"completed":"ongoing"}function ot(t){n.view=t,j(".view-section").forEach(e=>{e.classList.toggle("hidden",e.dataset.view!==t)}),j("[data-view]").forEach(e=>{e.classList.toggle("active",e.dataset.view===t)}),Ut(t).catch(e=>{console.error("Failed to load view",e)})}function xt(t,e){localStorage.setItem("lh_admin_token",t),localStorage.setItem("lh_admin_user",JSON.stringify(e)),n.token=t,n.user=e}function W(){localStorage.removeItem("lh_admin_token"),localStorage.removeItem("lh_admin_user"),n.token=null,n.user=null}function Lt(){return window.location.pathname==="/admin"}function Ft(){return window.location.pathname.startsWith("/admin/dashboard")}function J(){if(Et(),!Lt()){window.location.assign("/admin");return}U(o(".bg-aurora")),U(o("#login-view")),G(o("#app-view"))}function Nt(){if(!Ft()){window.location.assign("/admin/dashboard");return}if(G(o(".bg-aurora")),G(o("#login-view")),U(o("#app-view")),Ot(),n.user){const t=n.user.name?.trim()||"LaundryHub Admin",e="Admin",s=e.charAt(0).toUpperCase()||"A",a=n.user.email||"admin@laundryhub.com";d("#user-name",t),d("#user-email",n.user.email||""),d("#header-admin-name",e),d("#header-admin-avatar",s),d("#sidebar-admin-name",e),d("#sidebar-admin-email",a),d("#sidebar-admin-avatar",s)}}function Ot(){const t=o("#app-view");if(!t||t.classList.contains("hidden"))return;const e=[".sidebar",".mobile-topbar","#login-view",".drawer",".modal"];j("body *").forEach(a=>{if(!(a instanceof HTMLElement)||a.id==="app-view"||a.id==="login-view"||e.some(m=>a.closest(m)))return;const i=a.getBoundingClientRect();if(i.width<320||i.height<320)return;const r=window.getComputedStyle(a);if(!(["fixed","absolute"].includes(r.position)||r.pointerEvents==="none"||Number(r.opacity||"1")<.35))return;const c=`${a.className||""}`.toLowerCase(),p=`${a.id||""}`.toLowerCase();(c.includes("watermark")||c.includes("logo")||c.includes("aurora")||c.includes("bg-")||p.includes("watermark")||p.includes("logo")||r.zIndex==="0"&&r.pointerEvents==="none")&&(a.style.display="none")})}function gt(){o(".sidebar")?.classList.remove("open"),o("#sidebar-overlay")?.classList.remove("show"),o("#sidebar-toggle")?.setAttribute("aria-expanded","false")}function Pt(){const t=o(".sidebar"),e=o("#sidebar-overlay"),s=o("#sidebar-toggle");if(!t||!e||!s)return;const a=t.classList.toggle("open");e.classList.toggle("show",a),s.setAttribute("aria-expanded",a?"true":"false")}function mt(t){const e=o("#login-submit"),s=o("#login-submit .btn-spinner"),a=o("#login-submit .btn-label"),i=o("#login-email"),r=o("#login-password");e&&(e.disabled=t,e.classList.toggle("is-loading",t),e.setAttribute("aria-busy",t?"true":"false")),s&&s.classList.toggle("hidden",!t),a&&(a.textContent=t?"Signing in...":"Sign in"),i&&(i.disabled=t),r&&(r.disabled=t)}function nt(t){const e=o("#logout-modal-confirm"),s=o("#logout-modal-confirm .btn-spinner"),a=o("#logout-modal-confirm .btn-label"),i=o("#logout-modal-cancel");e&&(e.disabled=t,e.classList.toggle("is-loading",t),e.setAttribute("aria-busy",t?"true":"false")),s&&s.classList.toggle("hidden",!t),a&&(a.textContent=t?"Logging out...":"Yes"),i&&(i.disabled=t)}async function y(t,e={}){const s=new AbortController,a=Number.isFinite(e.timeoutMs)?e.timeoutMs:2e4,i=a>0?setTimeout(()=>s.abort(),a):null,r={method:e.method||"GET",headers:{Accept:"application/json",...e.headers},signal:s.signal};!e.skipAuth&&n.token&&(r.headers.Authorization=`Bearer ${n.token}`),e.body&&(r.headers["Content-Type"]="application/json",r.body=JSON.stringify(e.body));try{const l=await fetch(`${Dt}${t}`,r);i&&clearTimeout(i);let c=null;try{c=await l.json()}catch{c=null}return(l.status===401||l.status===403)&&(W(),J(),x("Session expired. Please sign in again.")),{ok:l.ok,status:l.status,data:c}}catch(l){return i&&clearTimeout(i),l?.name==="AbortError"?(x("Request timed out. The server may still be starting up."),{ok:!1,status:408,data:{message:"Request timed out."}}):(x("Network error. Please try again."),{ok:!1,status:0,data:null})}}async function Ht(){const t=Lt(),e=localStorage.getItem("lh_admin_token"),s=localStorage.getItem("lh_admin_user");if(!e||!s){W(),J();return}let a=null;try{a=JSON.parse(s)}catch{W(),J();return}if(!a||et(a.role)!=="admin"){W(),J();return}if(t){window.location.assign("/admin/dashboard");return}n.token=e,n.user=a,Nt(),ot("dashboard");const i=await y("/user");i.ok&&et(i.data?.role)==="admin"&&xt(e,i.data)}async function It(t){if(t.preventDefault(),n.isLoginSubmitting)return;const e=o("#login-email")?.value.trim()||"",s=o("#login-password")?.value||"",a=o("#login-error");G(a),n.isLoginSubmitting=!0,mt(!0);let i=!1,r;try{if(r=await y("/login",{method:"POST",body:{email:e,password:s},skipAuth:!0,timeoutMs:45e3}),!r.ok){const m=r.data?.message||`Login failed (Status: ${r.status||"Unknown"})`;d(a,m),U(a);return}const l=r.data?.user||r.data?.data?.user||null,c=`${r.data?.token||r.data?.access_token||r.data?.data?.token||r.data?.data?.access_token||""}`.trim(),p=et(l?.role||r.data?.role||r.data?.data?.role);if(!c){d(a,"Login failed. Missing access token."),U(a);return}if(p!=="admin"){d(a,"This account does not have admin access."),U(a);return}xt(c,l||{role:"admin",email:e}),i=!0,window.location.assign("/admin/dashboard")}finally{n.isLoginSubmitting=!1,i||mt(!1)}}async function zt(){Bt()}function Bt(){n.isLogoutSubmitting||(nt(!1),o("#logout-modal-overlay")?.classList.add("show"),o("#logout-modal")?.classList.remove("hidden"),o("#logout-modal")?.classList.add("show"))}function bt(){n.isLogoutSubmitting||(nt(!1),o("#logout-modal-overlay")?.classList.remove("show"),o("#logout-modal")?.classList.remove("show"),o("#logout-modal")?.classList.add("hidden"))}async function Rt(){if(!n.isLogoutSubmitting){n.isLogoutSubmitting=!0,nt(!0);try{n.token&&await y("/logout",{method:"POST"})}catch{}finally{W(),window.location.assign("/admin")}}}async function Ut(t){t==="dashboard"?await jt():t==="bookings"?await R():t==="customers"?await K():t==="analytics"?await Qt():t==="services"&&await it()}async function jt(){d("#stat-total-bookings","--"),d("#stat-pending","--"),d("#stat-revenue","--"),d("#stat-customers","--");const[t,e,s]=await Promise.all([y("/admin/stats"),y("/admin/orders/recent"),y("/admin/top-customers")]);if(t.ok&&t.data){const a=t.data.total_bookings??0,i=t.data.pending_count??0,r=t.data.revenue_today??0,l=t.data.customer_count??0;d("#stat-total-bookings",a),d("#stat-pending",i),d("#stat-revenue",_(r)),d("#stat-customers",l);const c=o("#stat-badge-total");c&&(c.className="stat-badge green",c.textContent="All time");const p=o("#stat-badge-pending");p&&(i>0?(p.className="stat-badge amber",p.textContent="Needs action"):(p.className="stat-badge green",p.textContent="All clear"));const u=o("#stat-badge-revenue");u&&(r>0?(u.className="stat-badge green",u.textContent="Earning today"):(u.className="stat-badge red",u.textContent="No revenue yet"));const m=o("#stat-badge-customers");m&&(m.className="stat-badge green",m.textContent="Growing")}qt(e.ok?e.data?.data||[]:[]),st(s.ok?s.data?.data||[]:[],"#top-customers-body")}function qt(t){const e=o("#recent-orders-body");if(e){if(e.innerHTML="",!t.length){e.innerHTML='<tr><td colspan="5">No recent orders.</td></tr>';return}t.forEach(s=>{const a=document.createElement("tr"),i=(s.status||"").toString().toLowerCase();a.innerHTML=`
      <td><span class="order-id">${s.id||""}</span></td>
      <td>${s.customer_name||"Unknown"}</td>
      <td>${s.service_type||"Service"}</td>
      <td>${_(s.total_price||0)}</td>
      <td><span class="status-pill" data-status="${i}">${s.status||"Pending"}</span></td>
    `,e.appendChild(a)})}}const ft=[{bg:"#EDE9FE",color:"#5B21B6"},{bg:"#CCFBF1",color:"#0F766E"},{bg:"#DBEAFE",color:"#1D4ED8"},{bg:"#FFE4E6",color:"#BE123C"},{bg:"#FEF3C7",color:"#92400E"},{bg:"#D1FAE5",color:"#065F46"}],Vt=["gold","silver","bronze","plain"],Wt=["1","2","3","4"];function st(t,e){const s=typeof e=="string"?o(e):e;if(s){if(s.innerHTML="",!t.length){s.innerHTML='<div style="font-size:13px;color:var(--color-text-secondary)">No data yet.</div>';return}t.forEach((a,i)=>{const r=(a.name||"C").split(" ").map(m=>m[0]).join("").toUpperCase().slice(0,2),l=ft[i%ft.length],c=Vt[Math.min(i,3)],p=Wt[Math.min(i,3)],u=document.createElement("div");u.className="top-customer-row",u.innerHTML=`
      <span class="medal-dot ${c}">${p}</span>
      <span class="customer-avatar" style="background:${l.bg};color:${l.color}">${r}</span>
      <div class="top-customer-info">
        <div class="top-customer-name">${a.name||"Customer"}</div>
        <div class="top-customer-meta">${a.orders||0} orders</div>
      </div>
      <div class="top-customer-spend">${a.spend||""}</div>
    `,s.appendChild(u)})}}function Z(t){j("#booking-status-chips [data-status]").forEach(e=>{e.classList.toggle("active",e.dataset.status===t)})}async function Yt(){const t=await y("/admin/booking-summaries");if(!t.ok)return;const e=t.data?.data||{},s=e.by_status||{},a=e.total??0;j("[data-status-count]").forEach(i=>{const r=i.dataset.statusCount,l=r==="all"?a:s[r]??0;d(i,l)})}function $t(t,e){const s=At(e);return e==="ready"||e==="completed"?(n.bookings.steps[t]=s,s):n.bookings.steps[t]!==void 0?n.bookings.steps[t]:s!==null?(n.bookings.steps[t]=s,s):null}function Kt(t,e){return e===null?"":["Washing","Drying","Ready","Done"].map((a,i)=>`<button class="step-chip ${i===e?"active":""}" data-booking-step="${i}" data-order-id="${t}" type="button">${a}</button>`).join("")}function Jt(t,e){const s=[];return e==="pending"&&(s.push(`<button class="button-outline btn-sm btn-success" data-booking-action="accept" data-order-id="${t}" type="button">Accept</button>`),s.push(`<button class="button-outline btn-sm btn-danger" data-booking-action="decline" data-order-id="${t}" type="button">Decline</button>`)),(e==="ongoing"||e==="ready")&&s.push(`<button class="button-outline btn-sm btn-success" data-booking-action="complete" data-order-id="${t}" type="button">Complete</button>`),s.join("")}function _t(t){const e=String(t),s=n.bookings.byId[e];if(!s)return;n.bookings.activeOrderId=e;const a=o("#booking-modal"),i=o("#booking-modal-overlay"),r=o("#booking-modal-body"),l=o("#booking-modal-title"),c=o("#booking-modal-subtitle"),p=at(s),u=Q(s.status)||"pending";l&&(l.textContent="Booking details"),c&&(c.textContent=`${p} · ${u}`),r&&(r.innerHTML=Tt(s)),i&&i.classList.add("show"),a&&(a.classList.add("show"),a.classList.remove("hidden"))}function Et(){n.bookings.activeOrderId=null,o("#booking-modal-overlay")?.classList.remove("show");const t=o("#booking-modal");t&&(t.classList.remove("show"),t.classList.add("hidden"))}function vt(t){const e=t.dataset.orderId,s=t.dataset.bookingAction;s==="accept"?(n.bookings.steps[e]=0,Y(e,"ongoing")):s==="decline"?Y(e,"cancelled"):s==="complete"&&(n.bookings.steps[e]=3,Y(e,"completed"))}function yt(t){const e=t.dataset.orderId,s=Number(t.dataset.bookingStep);Number.isNaN(s)||(n.bookings.steps[e]=s,Y(e,Mt(s)))}async function R(){const t=Yt(),e=o("#bookings-filter");e&&(e.value=n.bookings.status);const s=new URLSearchParams({page:n.bookings.page.toString(),per_page:n.bookings.perPage.toString()});n.bookings.status&&n.bookings.status!=="all"&&s.set("status",n.bookings.status);const a=await y(`/admin/orders?${s.toString()}`),i=o("#bookings-table-body");if(!i)return;if(i.innerHTML="",!a.ok){i.innerHTML='<tr><td colspan="8">Unable to load bookings.</td></tr>';return}const r=a.data?.data||[],l=a.data?.pagination||{};if(n.bookings.byId={},!r.length){i.innerHTML='<tr><td colspan="8">No bookings found.</td></tr>',await t,Z(n.bookings.status);return}r.forEach(g=>{const L=g.order_id||g.id,k=String(L);n.bookings.byId[k]=g;const b=Q(g.status);$t(L,b);const w=document.createElement("tr"),C=(g.customer_name||"Customer").split(" ").map(F=>F[0]).join("").substring(0,2).toUpperCase(),E=S(g.created_at),D=at(g),A=[{bg:"#EEEDFE",color:"#3C3489"},{bg:"#E1F5EE",color:"#085041"},{bg:"#E6F1FB",color:"#0C447C"}],M=A[(g.customer_id||0)%A.length];w.innerHTML=`
      <td><span class="order-id">${D}</span></td>
      <td>
        <div class="order-customer-cell">
          <span class="order-customer-avatar" style="background:${M.bg};color:${M.color}">${C}</span>
          <span class="order-customer-name">${g.customer_name||"Unknown"}</span>
        </div>
      </td>
      <td>${g.service_type||"Service"}</td>
      <td>${g.weight_kg||0} kg</td>
      <td>${_(g.total_price||0)}</td>
      <td>
        <span class="status-pill" data-status="${b}">
          <span class="status-dot"></span>
          ${b}
        </span>
      </td>
      <td><span class="order-created-date">${E}</span></td>
      <td>
        <div style="display:flex; gap:6px; align-items:center;">
          <button class="btn-action-pill btn-action-details" data-booking-toggle="${L}" type="button">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            Details
          </button>
          <button class="btn-action-pill btn-action-receipt" data-cod-receipt-id="${L}" type="button">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
            Receipt
          </button>
        </div>
      </td>
    `,i.appendChild(w)});const c=l.total||r.length;d("#bookings-footer-info",`Showing ${r.length} of ${c} orders — Page ${l.current_page||1} of ${l.last_page||1}`);const p=o("#bookings-prev"),u=o("#bookings-next"),m=o("#bookings-current-page");p&&(p.disabled=(l.current_page||1)<=1),u&&(u.disabled=(l.current_page||1)>=(l.last_page||1)),m&&(m.textContent=l.current_page||1),await t,Z(n.bookings.status)}async function Y(t,e){const s=String(t),a=await y(`/admin/orders/${t}/status`,{method:"PATCH",body:{status:e}});if(!a.ok){x("Unable to update status.");return}x("Order status updated.");const i=a.data?.data;await R(),i&&(n.bookings.byId[s]=i),n.bookings.activeOrderId===s&&_t(t)}async function K(){const t=new URLSearchParams({page:n.customers.page.toString(),per_page:n.customers.perPage.toString()});n.customers.search&&t.set("search",n.customers.search);const e=await y(`/admin/customers?${t.toString()}`),s=o("#customers-table-body");if(!s)return;if(s.innerHTML="",!e.ok){s.innerHTML='<tr><td colspan="6">Unable to load customers.</td></tr>';return}const a=e.data?.data||[],i=e.data?.pagination||{};a.length||(s.innerHTML='<tr><td colspan="6">No customers found.</td></tr>'),a.forEach(c=>{const p=document.createElement("tr");p.innerHTML=`
      <td>
        <div class="font-semibold">${c.name||"Customer"}</div>
        <div class="text-xs text-slate-500">${c.email||""}</div>
      </td>
      <td>${c.phone||"---"}</td>
      <td>${c.orders_count||0}</td>
      <td>${_(c.total_spent||0)}</td>
      <td>${c.loyalty_points||0}</td>
      <td>
        <button class="button-outline" data-customer-id="${c.id}">View</button>
      </td>
    `,s.appendChild(p)}),d("#customers-page-info",`Page ${i.current_page||1} of ${i.last_page||1}`);const r=o("#customers-prev"),l=o("#customers-next");r&&(r.disabled=(i.current_page||1)<=1),l&&(l.disabled=(i.current_page||1)>=(i.last_page||1))}async function Gt(t){n.currentCustomerId=t,o("#customer-drawer")?.classList.add("open"),o("#drawer-overlay")?.classList.add("show"),d("#customer-drawer-title","Loading...");const e=await y(`/admin/customers/${t}`);if(!e.ok){x("Unable to load customer.");return}const s=e.data?.data||{};d("#customer-drawer-title",s.name||"Customer"),o("#customer-name").value=s.name||"",o("#customer-email").value=s.email||"",o("#customer-phone").value=s.phone||"",o("#customer-address").value=s.address||"",o("#customer-city").value=s.city||"",o("#customer-zip").value=s.zip_code||"",o("#customer-country").value=s.country||"",o("#customer-notifications").checked=s.notifications_enabled!==!1,d("#customer-loyalty",s.loyalty_points||0),d("#customer-orders-count",s.orders_count||0),d("#customer-total-spent",_(s.total_spent||0)),d("#customer-dob",I(S(s.date_of_birth))),d("#customer-gender",I(s.gender)),d("#customer-language",I(s.preferred_language)),d("#customer-email-verified",pt(!!s.email_verified_at)),d("#customer-profile-completed",pt(!!s.profile_completed_at)),d("#customer-member-since",I(S(s.created_at))),d("#customer-last-login",I(S(s.last_login_at))),d("#customer-bio",I(s.bio)),n.customerOrders.page=1,n.customerOrders.lastPage=1,await Ct(!0)}function ht(){o("#customer-drawer")?.classList.remove("open"),o("#drawer-overlay")?.classList.remove("show"),n.currentCustomerId=null}async function Zt(){if(!n.currentCustomerId)return;const t={name:o("#customer-name").value.trim(),phone:o("#customer-phone").value.trim()||null,address:o("#customer-address").value.trim()||null,city:o("#customer-city").value.trim()||null,zip_code:o("#customer-zip").value.trim()||null,country:o("#customer-country").value.trim()||null,notifications_enabled:o("#customer-notifications").checked};if(!(await y(`/admin/customers/${n.currentCustomerId}`,{method:"PUT",body:t})).ok){x("Unable to update customer.");return}x("Customer updated."),await K()}async function Ct(t=!1){if(!n.currentCustomerId)return;t&&(n.customerOrders.page=1);const e=new URLSearchParams({page:n.customerOrders.page.toString(),per_page:n.customerOrders.perPage.toString()}),s=await y(`/admin/customers/${n.currentCustomerId}/orders?${e.toString()}`),a=o("#customer-orders-body");if(!a)return;if(!s.ok){t&&(a.innerHTML='<tr><td colspan="5">Unable to load orders.</td></tr>');return}const i=s.data?.data||[],r=s.data?.pagination||{};t&&(a.innerHTML=""),!i.length&&t&&(a.innerHTML='<tr><td colspan="5">No orders yet.</td></tr>'),i.forEach(u=>{const m=document.createElement("tr");m.innerHTML=`
      <td>${u.id||""}</td>
      <td>${u.service_type||""}</td>
      <td>${u.weight_kg||0} kg</td>
      <td>${_(u.total_price||0)}</td>
      <td>${u.status||""}</td>
    `,a.appendChild(m)}),n.customerOrders.lastPage=r.last_page||1;const l=r.current_page||n.customerOrders.page;d("#customer-orders-page-info",`Page ${l} of ${n.customerOrders.lastPage}`);const c=Number.isFinite(r.total)?r.total:i.length;d("#customer-orders-title-count",`(${c})`);const p=o("#customer-orders-load");if(p){const u=l>=n.customerOrders.lastPage;p.disabled=u,p.classList.toggle("hidden",u||c===0)}}async function Qt(){const t=await y("/admin/analytics");if(!t.ok){x("Unable to load analytics.");return}const e=t.data||{},s=Number(e.monthly_revenue||0),a=Number(e.total_orders_this_month||0),i=Number(e.completed_orders_this_month||0),r=Number(e.cancelled_orders_this_month||0),l=Number(e.new_customers_this_month||0),c=Number(e.total_customers||0),p=Number(e.completion_rate||0),u=e.top_service||null,m=Array.isArray(e.top_customers)?e.top_customers:[],g=m[0]||null;d("#analytics-month",e.month_label||""),d("#analytics-monthly-revenue",_(s)),d("#analytics-monthly-card",_(s)),d("#analytics-completion-rate",`${p}%`),d("#analytics-monthly-orders",a),d("#analytics-new-customers",l),d("#analytics-total-customers",`${c} total customers`),d("#analytics-completed-orders",i),d("#analytics-cancelled-orders",`${r} cancelled`),d("#analytics-top-service",u?.name||"No service data yet"),d("#analytics-top-service-meta",u?`${u.orders||0} orders`:"No completed order mix yet"),d("#analytics-top-customer",g?.name||"No customer data yet"),d("#analytics-top-customer-meta",g?`${g.orders||0} orders · ${g.spend_label||_(g.spend||0)}`:"No customer orders yet"),d("#analytics-order-health",`${p}% completion`);const L=e.weekly_revenue||[],k=Math.max(1,...L.map(v=>Number(v||0))),b=["Mon","Tue","Wed","Thu","Fri","Sat","Sun"],w=o("#weekly-bars");w.innerHTML="",L.forEach((v,N)=>{const $=Math.round(Number(v||0)/k*100),T=document.createElement("div");T.className="weekly-bar",T.innerHTML=`
      <div class="weekly-bar-value">${_(Number(v||0))}</div>
      <div class="weekly-bar-track" title="${_(Number(v||0))}">
        <div class="weekly-bar-fill" style="height:${$}%;"></div>
      </div>
      <div class="weekly-bar-label">${b[N]||""}</div>
    `,w.appendChild(T)});const C=e.service_breakdown||[],E=o("#service-breakdown-body"),D=o("#service-breakdown-donut"),A=o("#service-breakdown-total");E&&(E.innerHTML="");const M=["#3B82F6","#34D399","#F59E0B","#EC4899","#A78BFA","#22D3EE"];let F=0,P=0;const z=[];if(!C.length)E&&(E.innerHTML='<div class="analytics-empty">No service data yet.</div>'),D&&(D.style.background="conic-gradient(rgba(148, 163, 184, 0.2) 0% 100%)"),A&&d("#service-breakdown-total","0%");else if(C.forEach((v,N)=>{const $=Math.max(0,Math.min(100,Number(v.pct||0))),T=M[N%M.length];if($>0&&z.push(`${T} ${F}% ${F+$}%`),F+=$,P+=$,E){const B=document.createElement("div");B.className="breakdown-legend-row",B.innerHTML=`
          <span class="breakdown-legend-swatch" style="background:${T};"></span>
          <div class="breakdown-legend-copy">
            <div class="breakdown-legend-name">${V(v.name||"Service")}</div>
            <div class="breakdown-legend-meta">${$}% &middot; ${v.count||0} orders</div>
          </div>
        `,E.appendChild(B)}}),D){const v=Math.min(100,Math.round(P));P<100&&z.push(`rgba(148, 163, 184, 0.2) ${P}% 100%`),D.style.background=`conic-gradient(${z.join(", ")})`,A&&d("#service-breakdown-total",`${v}%`)}const H=o("#analytics-top-customers-list");H&&(H.innerHTML="",m.length?m.forEach((v,N)=>{const $=document.createElement("div");$.className="analytics-customer-row",$.innerHTML=`
          <span class="analytics-rank">${N+1}</span>
          <div class="analytics-customer-copy">
            <strong>${V(v.name||"Customer")}</strong>
            <span>${v.orders||0} orders</span>
          </div>
          <div class="analytics-customer-spend">${v.spend_label||_(v.spend||0)}</div>
        `,H.appendChild($)}):H.innerHTML='<div class="analytics-empty">No customer spend data yet.</div>')}async function it(){const[t,e]=await Promise.all([y("/admin/services"),y("/admin/top-customers")]),s=o("#services-table-body");if(!s)return;if(s.innerHTML="",!t.ok){s.innerHTML='<tr><td colspan="6">Unable to load services.</td></tr>',st(e.ok?e.data?.data||[]:[],"#services-top-customers-body");return}const a=t.data?.data||[];a.length||(s.innerHTML='<tr><td colspan="6">No services found.</td></tr>'),a.forEach(i=>{const r=document.createElement("tr");r.innerHTML=`
      <td>
        <div class="font-semibold">${i.name||"Service"}</div>
        <div class="text-xs text-slate-500">${i.description||""}</div>
      </td>
      <td>${_(i.price_per_kg||0)}</td>
      <td>${i.category||"---"}</td>
      <td>${i.is_active?"Active":"Inactive"}</td>
      <td class="space-x-2">
        <button class="button-outline" data-edit-service="${i.id}">Edit</button>
        <button class="button-outline" data-delete-service="${i.id}">Delete</button>
      </td>
    `,s.appendChild(r)}),st(e.ok?e.data?.data||[]:[],"#services-top-customers-body")}async function Xt(){const t={name:o("#service-name").value.trim(),description:o("#service-description").value.trim()||null,price_per_kg:Number(o("#service-price").value||0),category:o("#service-category").value.trim()||null,image_url:o("#service-image").value.trim()||null,is_active:o("#service-active").checked},e=n.services.editingId;if(!(await y(`/admin/services${e?`/${e}`:""}`,{method:e?"PUT":"POST",body:t})).ok){x("Unable to save service.");return}x(e?"Service updated.":"Service created."),St(),await it()}function St(){n.services.editingId=null,d("#service-form-title","Create service"),o("#service-name").value="",o("#service-description").value="",o("#service-price").value="",o("#service-category").value="",o("#service-image").value="",o("#service-active").checked=!0}async function te(t){const e=await y("/admin/services");if(!e.ok)return;const a=(e.data?.data||[]).find(i=>i.id===Number(t));a&&(n.services.editingId=a.id,d("#service-form-title","Update service"),o("#service-name").value=a.name||"",o("#service-description").value=a.description||"",o("#service-price").value=a.price_per_kg||"",o("#service-category").value=a.category||"",o("#service-image").value=a.image_url||"",o("#service-active").checked=a.is_active!==!1)}async function ee(t){if(!window.confirm("Delete this service?"))return;if(!(await y(`/admin/services/${t}`,{method:"DELETE"})).ok){x("Unable to delete service.");return}x("Service deleted."),await it()}function kt(t,e,s){t.type=s?"text":"password",e.setAttribute("aria-pressed",s?"true":"false"),e.setAttribute("aria-label",s?"Hide password":"Show password"),e.innerHTML=s?'<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>':'<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>'}function oe(){const t=o("#login-form");t&&t.addEventListener("submit",It);const e=o("#toggle-password"),s=o("#login-password");e&&s&&(kt(s,e,!1),e.addEventListener("click",()=>{const f=s.type==="password";kt(s,e,f)}));const a=o("#logout-button");a&&a.addEventListener("click",zt);const i=o("#logout-modal-cancel");i&&i.addEventListener("click",bt);const r=o("#logout-modal-confirm");r&&r.addEventListener("click",Rt);const l=o("#logout-modal-overlay");l&&l.addEventListener("click",bt),j("[data-view]").forEach(f=>{f.addEventListener("click",()=>{ot(f.dataset.view),gt()})});const c=o("#bookings-filter");c&&c.addEventListener("change",f=>{n.bookings.status=f.target.value,n.bookings.page=1,Z(n.bookings.status),R()});const p=o("#booking-status-chips");p&&p.addEventListener("click",f=>{const h=f.target.closest("[data-status]");h&&(n.bookings.status=h.dataset.status,n.bookings.page=1,Z(n.bookings.status),c&&(c.value=n.bookings.status),R())});const u=o("#bookings-prev");u&&u.addEventListener("click",()=>{n.bookings.page=Math.max(1,n.bookings.page-1),R()});const m=o("#bookings-next");m&&m.addEventListener("click",()=>{n.bookings.page+=1,R()});const g=o("#bookings-table-body");g&&(g.addEventListener("change",f=>{const h=f.target.closest("select[data-order-id]");h&&Y(h.dataset.orderId,h.value)}),g.addEventListener("click",f=>{const h=f.target.closest("[data-cod-receipt-id]");if(h){const X=h.dataset.codReceiptId,ut=n.bookings.byId[String(X)];ut?se(ut):x("Receipt data unavailable. Please refresh.");return}const O=f.target.closest("[data-booking-toggle]");if(O){const X=O.dataset.bookingToggle;_t(X);return}const ct=f.target.closest("[data-booking-action]");if(ct){vt(ct);return}const lt=f.target.closest("[data-booking-step]");lt&&yt(lt)}));const L=o("#booking-modal-close");L&&L.addEventListener("click",Et);const k=o("#booking-modal");k&&k.addEventListener("click",f=>{const h=f.target.closest("[data-booking-action]");if(h){vt(h);return}const O=f.target.closest("[data-booking-step]");O&&yt(O)});const b=o("#customers-search-button");b&&b.addEventListener("click",()=>{n.customers.search=o("#customers-search-input").value.trim(),n.customers.page=1,K()});const w=o("#customers-prev");w&&w.addEventListener("click",()=>{n.customers.page=Math.max(1,n.customers.page-1),K()});const C=o("#customers-next");C&&C.addEventListener("click",()=>{n.customers.page+=1,K()});const E=o("#customers-table-body");E&&E.addEventListener("click",f=>{const h=f.target.closest("[data-customer-id]");h&&Gt(h.dataset.customerId)});const D=o("#customer-drawer-close");D&&D.addEventListener("click",ht);const A=o("#drawer-overlay");A&&A.addEventListener("click",ht);const M=o("#customer-save");M&&M.addEventListener("click",Zt);const F=o("#customer-orders-load");F&&F.addEventListener("click",()=>{n.customerOrders.page>=n.customerOrders.lastPage||(n.customerOrders.page+=1,Ct())});const P=o("#service-save");P&&P.addEventListener("click",Xt);const z=o("#service-clear");z&&z.addEventListener("click",St);const H=o("#services-table-body");H&&H.addEventListener("click",f=>{const h=f.target.closest("[data-edit-service]");if(h){te(h.dataset.editService);return}const O=f.target.closest("[data-delete-service]");O&&ee(O.dataset.deleteService)});const v=o("#recent-orders-view-all");v&&v.addEventListener("click",()=>ot("bookings"));const N=o("#sidebar-toggle");N&&N.addEventListener("click",Pt);const $=o("#sidebar-overlay");$&&$.addEventListener("click",gt);const T=o("#cod-receipt-close");T&&T.addEventListener("click",tt);const B=o("#cod-receipt-cancel");B&&B.addEventListener("click",tt);const rt=o("#cod-receipt-print");rt&&rt.addEventListener("click",ae);const dt=o("#cod-receipt-overlay");dt&&dt.addEventListener("click",tt)}window.addEventListener("DOMContentLoaded",()=>{oe(),Ht()});function se(t){const e=o("#cod-receipt-modal"),s=o("#cod-receipt-overlay"),a=o("#cod-receipt-body");if(!e||!s||!a)return;const i=at(t),r=wt(t.delivery_type),l=S(t.pickup_date),c=S(t.delivery_date),p=S(t.created_at),u=_(t.total_price||0),m=new Date().toLocaleDateString("en-PH",{month:"short",day:"numeric",year:"numeric"}),g=(L,k,b="")=>`
    <tr>
      <td style="padding:9px 12px; color:#58708D; font-size:12px; font-weight:500; width:42%; white-space:nowrap; vertical-align:middle;">
        ${b?`<span style="margin-right:5px; opacity:0.7;">${b}</span>`:""}${L}
      </td>
      <td style="padding:9px 12px; color:#08213D; font-size:12.5px; font-weight:600; vertical-align:middle;">${k}</td>
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
            ${g("Customer",V(t.customer_name||"N/A"),"👤")}
            ${g("Address",V(t.pickup_address||"N/A"),"📍")}
            <tr style="background:#F8FBFF;">
              <td colspan="2" style="padding:7px 12px; font-size:10px; font-weight:800; letter-spacing:0.12em; text-transform:uppercase; color:#58708D;">Order Details</td>
            </tr>
            ${g("Service",V(t.service_type||"---"),"🧺")}
            ${g("Weight",`${t.weight_kg||0} kg`,"⚖️")}
            ${g("Fulfillment",r,"🚚")}
            ${g("Pickup Date",l,"📅")}
            ${g("Delivery Date",c,"📅")}
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
  `,e.classList.remove("hidden"),e.classList.add("show"),s.classList.add("show")}function tt(){const t=o("#cod-receipt-modal"),e=o("#cod-receipt-overlay");t&&(t.classList.remove("show"),t.classList.add("hidden")),e&&e.classList.remove("show")}function ae(){const t=o("#cod-receipt-modal");if(!t||t.classList.contains("hidden")){x("Open a receipt first.");return}const e=Array.from(t.querySelectorAll("#cod-receipt-print-area table tbody tr")).filter(b=>!b.querySelector("[colspan]")).map(b=>{const w=b.querySelectorAll("td");if(w.length<2)return null;const C=w[0].textContent.replace(/[\u{1F000}-\u{1FFFF}]/gu,"").trim(),E=w[1].textContent.trim();return{label:C,value:E}}).filter(Boolean);t.querySelector(".btn-action-receipt")?.dataset?.codReceiptId;const s=t.querySelector("#cod-receipt-print-area > div:first-child"),a=s?s.querySelectorAll("div"):[],i=a[2]?.textContent?.trim()||"",r=a[3]?.textContent?.trim()||"",c=t.querySelector('#cod-receipt-print-area [style*="font-size:26px"]')?.textContent?.trim()||"";e.map(({label:b,value:w})=>`
    <tr>
      <td class="label-col">${b}</td>
      <td class="value-col">${w}</td>
    </tr>`).join("");const p=["Customer","Address"],u=e.filter(b=>p.includes(b.label)),m=e.filter(b=>!p.includes(b.label)),g=b=>b.map(({label:w,value:C})=>`
    <tr>
      <td class="label">${w}</td>
      <td class="value">${C}</td>
    </tr>`).join(""),L=`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>COD Receipt ${i}</title>
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
      <div class="order-pill">${i}</div>
      <div class="issued">${r}</div>
    </div>

    <div class="section">
      <div class="section-head">Customer Information</div>
      <table>
        ${g(u)}
      </table>

      <div class="section-head">Order Details</div>
      <table>
        ${g(m)}
      </table>
    </div>

    <div class="total-box">
      <div>
        <div class="total-label">Total Amount Paid</div>
        <div class="total-amount">${c}</div>
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
</html>`,k=window.open("","_blank","width=680,height=860");if(!k){x("Allow pop-ups to print/save this receipt.");return}k.document.open(),k.document.write(L),k.document.close(),k.onload=()=>{k.focus(),k.print()}}
