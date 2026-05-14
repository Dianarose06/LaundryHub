import"./app-UyRVujZY.js";const i={token:null,user:null,isLoginSubmitting:!1,isLogoutSubmitting:!1,view:"dashboard",bookings:{page:1,perPage:20,status:"all",steps:{},byId:{},activeOrderId:null},customers:{page:1,perPage:20,search:""},services:{editingId:null},customerOrders:{page:1,perPage:10,lastPage:1},currentCustomerId:null},s=(t,e=document)=>e.querySelector(t),V=(t,e=document)=>Array.from(e.querySelectorAll(t)),St=`${window.LAUNDRYHUB_API_BASE_URL||"/api"}`.replace(/\/$/,"");function d(t,e){const o=typeof t=="string"?s(t):t;o&&(o.textContent=e)}function q(t){t&&t.classList.remove("hidden")}function Z(t){t&&t.classList.add("hidden")}function h(t){const e=s("#toast");e&&(e.textContent=t,e.classList.add("show"),e.setAttribute("aria-hidden","false"),setTimeout(()=>{e.classList.remove("show"),e.setAttribute("aria-hidden","true")},3e3))}function L(t){return`PHP ${Number(t||0).toLocaleString("en-PH",{maximumFractionDigits:0})}`}function E(t){if(!t)return"---";const e=new Date(t);return Number.isNaN(e.getTime())?t:e.toLocaleDateString("en-PH",{month:"short",day:"numeric",year:"numeric"})}function z(t,e="---"){return t==null||t===""?e:t}function A(t){return`${t??""}`.replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;").replaceAll('"',"&quot;").replaceAll("'","&#039;")}function ut(t){return t?"Yes":"No"}function et(t){return`${t||""}`.trim().toLowerCase()}function I(t){return(t||"").toString().toLowerCase()}function kt(t){return(I(t)||"pickup")==="delivery"?"Delivery":"Pickup"}function G(t){const e=t?.id??t?.order_id??"",o=String(e).replace(new RegExp("^#?LH-+"),"");return o?`#LH-${o.padStart(3,"0")}`:String(e||"---")}function Dt(t){const e=t.order_id||t.id,o=I(t.status),a=Lt(e,o),n=E(t.pickup_date),r=E(t.delivery_date||t.pickup_date),u=kt(t.delivery_type),c=z(t.pickup_address),l=E(t.updated_at),p=["ongoing","ready","completed"].includes(o)?Yt(e,a):"",m=Kt(e,o);return`
    <div class="details-grid">
      <div>
        <div class="details-label">Pickup date</div>
        <div class="details-value">${n}</div>
      </div>
      <div>
        <div class="details-label">Delivery date</div>
        <div class="details-value">${r}</div>
      </div>
      <div>
        <div class="details-label">Delivery type</div>
        <div class="details-value">${u}</div>
      </div>
      <div>
        <div class="details-label">Pickup address</div>
        <div class="details-value">${c}</div>
      </div>
      <div>
        <div class="details-label">Created</div>
        <div class="details-value">${E(t.created_at)}</div>
      </div>
      <div>
        <div class="details-label">Updated</div>
        <div class="details-value">${l}</div>
      </div>
    </div>
    <div class="details-actions">
      ${p?`<div class="step-chips">${p}</div>`:"<div></div>"}
      <div class="action-buttons">${m||'<span class="text-xs text-muted">No actions</span>'}</div>
    </div>
  `}function Tt(t){return t==="ready"?2:t==="completed"?3:t==="ongoing"?0:null}function At(t){return t===2?"ready":t===3?"completed":"ongoing"}function ot(t){i.view=t,V(".view-section").forEach(e=>{e.classList.toggle("hidden",e.dataset.view!==t)}),V("[data-view]").forEach(e=>{e.classList.toggle("active",e.dataset.view===t)}),Bt(t).catch(e=>{console.error("Failed to load view",e)})}function xt(t,e){localStorage.setItem("lh_admin_token",t),localStorage.setItem("lh_admin_user",JSON.stringify(e)),i.token=t,i.user=e}function W(){localStorage.removeItem("lh_admin_token"),localStorage.removeItem("lh_admin_user"),i.token=null,i.user=null}function wt(){return window.location.pathname==="/admin"}function Mt(){return window.location.pathname.startsWith("/admin/dashboard")}function J(){if(_t(),!wt()){window.location.assign("/admin");return}q(s(".bg-aurora")),q(s("#login-view")),Z(s("#app-view"))}function Ft(){if(!Mt()){window.location.assign("/admin/dashboard");return}if(Z(s(".bg-aurora")),Z(s("#login-view")),q(s("#app-view")),Nt(),i.user){const t=i.user.name?.trim()||"LaundryHub Admin",e="Admin",o=e.charAt(0).toUpperCase()||"A",a=i.user.email||"admin@laundryhub.com";d("#user-name",t),d("#user-email",i.user.email||""),d("#header-admin-name",e),d("#header-admin-avatar",o),d("#sidebar-admin-name",e),d("#sidebar-admin-email",a),d("#sidebar-admin-avatar",o)}}function Nt(){const t=s("#app-view");if(!t||t.classList.contains("hidden"))return;const e=[".sidebar",".mobile-topbar","#login-view",".drawer",".modal"];V("body *").forEach(a=>{if(!(a instanceof HTMLElement)||a.id==="app-view"||a.id==="login-view"||e.some(m=>a.closest(m)))return;const n=a.getBoundingClientRect();if(n.width<320||n.height<320)return;const r=window.getComputedStyle(a);if(!(["fixed","absolute"].includes(r.position)||r.pointerEvents==="none"||Number(r.opacity||"1")<.35))return;const c=`${a.className||""}`.toLowerCase(),l=`${a.id||""}`.toLowerCase();(c.includes("watermark")||c.includes("logo")||c.includes("aurora")||c.includes("bg-")||l.includes("watermark")||l.includes("logo")||r.zIndex==="0"&&r.pointerEvents==="none")&&(a.style.display="none")})}function pt(){s(".sidebar")?.classList.remove("open"),s("#sidebar-overlay")?.classList.remove("show"),s("#sidebar-toggle")?.setAttribute("aria-expanded","false")}function Ot(){const t=s(".sidebar"),e=s("#sidebar-overlay"),o=s("#sidebar-toggle");if(!t||!e||!o)return;const a=t.classList.toggle("open");e.classList.toggle("show",a),o.setAttribute("aria-expanded",a?"true":"false")}function gt(t){const e=s("#login-submit"),o=s("#login-submit .btn-spinner"),a=s("#login-submit .btn-label"),n=s("#login-email"),r=s("#login-password");e&&(e.disabled=t,e.classList.toggle("is-loading",t),e.setAttribute("aria-busy",t?"true":"false")),o&&o.classList.toggle("hidden",!t),a&&(a.textContent=t?"Signing in...":"Sign in"),n&&(n.disabled=t),r&&(r.disabled=t)}function at(t){const e=s("#logout-modal-confirm"),o=s("#logout-modal-confirm .btn-spinner"),a=s("#logout-modal-confirm .btn-label"),n=s("#logout-modal-cancel");e&&(e.disabled=t,e.classList.toggle("is-loading",t),e.setAttribute("aria-busy",t?"true":"false")),o&&o.classList.toggle("hidden",!t),a&&(a.textContent=t?"Logging out...":"Yes"),n&&(n.disabled=t)}async function y(t,e={}){const o=new AbortController,a=Number.isFinite(e.timeoutMs)?e.timeoutMs:2e4,n=a>0?setTimeout(()=>o.abort(),a):null,r={method:e.method||"GET",headers:{Accept:"application/json",...e.headers},signal:o.signal};!e.skipAuth&&i.token&&(r.headers.Authorization=`Bearer ${i.token}`),e.body&&(r.headers["Content-Type"]="application/json",r.body=JSON.stringify(e.body));try{const u=await fetch(`${St}${t}`,r);n&&clearTimeout(n);let c=null;try{c=await u.json()}catch{c=null}return(u.status===401||u.status===403)&&(W(),J(),h("Session expired. Please sign in again.")),{ok:u.ok,status:u.status,data:c}}catch(u){return n&&clearTimeout(n),u?.name==="AbortError"?(h("Request timed out. The server may still be starting up."),{ok:!1,status:408,data:{message:"Request timed out."}}):(h("Network error. Please try again."),{ok:!1,status:0,data:null})}}async function Pt(){const t=wt(),e=localStorage.getItem("lh_admin_token"),o=localStorage.getItem("lh_admin_user");if(!e||!o){W(),J();return}let a=null;try{a=JSON.parse(o)}catch{W(),J();return}if(!a||et(a.role)!=="admin"){W(),J();return}if(t){window.location.assign("/admin/dashboard");return}i.token=e,i.user=a,Ft(),ot("dashboard");const n=await y("/user");n.ok&&et(n.data?.role)==="admin"&&xt(e,n.data)}async function It(t){if(t.preventDefault(),i.isLoginSubmitting)return;const e=s("#login-email")?.value.trim()||"",o=s("#login-password")?.value||"",a=s("#login-error");Z(a),i.isLoginSubmitting=!0,gt(!0);let n=!1,r;try{if(r=await y("/login",{method:"POST",body:{email:e,password:o},skipAuth:!0,timeoutMs:45e3}),!r.ok){d(a,r.data?.message||"Login failed."),q(a);return}const u=r.data?.user||r.data?.data?.user||null,c=`${r.data?.token||r.data?.access_token||r.data?.data?.token||r.data?.data?.access_token||""}`.trim(),l=et(u?.role);if(!c){d(a,"Login failed. Missing access token."),q(a);return}if(l!=="admin"){d(a,"This account does not have admin access."),q(a);return}xt(c,u),n=!0,window.location.assign("/admin/dashboard")}finally{i.isLoginSubmitting=!1,n||gt(!1)}}async function Ht(){Rt()}function Rt(){i.isLogoutSubmitting||(at(!1),s("#logout-modal-overlay")?.classList.add("show"),s("#logout-modal")?.classList.remove("hidden"),s("#logout-modal")?.classList.add("show"))}function mt(){i.isLogoutSubmitting||(at(!1),s("#logout-modal-overlay")?.classList.remove("show"),s("#logout-modal")?.classList.remove("show"),s("#logout-modal")?.classList.add("hidden"))}async function zt(){if(!i.isLogoutSubmitting){i.isLogoutSubmitting=!0,at(!0);try{i.token&&await y("/logout",{method:"POST"})}catch{}finally{W(),window.location.assign("/admin")}}}async function Bt(t){t==="dashboard"?await Ut():t==="bookings"?await j():t==="customers"?await K():t==="analytics"?await Zt():t==="services"&&await nt()}async function Ut(){d("#stat-total-bookings","--"),d("#stat-pending","--"),d("#stat-revenue","--"),d("#stat-customers","--");const[t,e,o]=await Promise.all([y("/admin/stats"),y("/admin/orders/recent"),y("/admin/top-customers")]);if(t.ok&&t.data){const a=t.data.total_bookings??0,n=t.data.pending_count??0,r=t.data.revenue_today??0,u=t.data.customer_count??0;d("#stat-total-bookings",a),d("#stat-pending",n),d("#stat-revenue",L(r)),d("#stat-customers",u);const c=s("#stat-badge-total");c&&(c.className="stat-badge green",c.textContent="All time");const l=s("#stat-badge-pending");l&&(n>0?(l.className="stat-badge amber",l.textContent="Needs action"):(l.className="stat-badge green",l.textContent="All clear"));const p=s("#stat-badge-revenue");p&&(r>0?(p.className="stat-badge green",p.textContent="Earning today"):(p.className="stat-badge red",p.textContent="No revenue yet"));const m=s("#stat-badge-customers");m&&(m.className="stat-badge green",m.textContent="Growing")}jt(e.ok?e.data?.data||[]:[]),st(o.ok?o.data?.data||[]:[],"#top-customers-body")}function jt(t){const e=s("#recent-orders-body");if(e){if(e.innerHTML="",!t.length){e.innerHTML='<tr><td colspan="5">No recent orders.</td></tr>';return}t.forEach(o=>{const a=document.createElement("tr"),n=(o.status||"").toString().toLowerCase();a.innerHTML=`
      <td><span class="order-id">${o.id||""}</span></td>
      <td>${o.customer_name||"Unknown"}</td>
      <td>${o.service_type||"Service"}</td>
      <td>${L(o.total_price||0)}</td>
      <td><span class="status-pill" data-status="${n}">${o.status||"Pending"}</span></td>
    `,e.appendChild(a)})}}const bt=[{bg:"#EDE9FE",color:"#5B21B6"},{bg:"#CCFBF1",color:"#0F766E"},{bg:"#DBEAFE",color:"#1D4ED8"},{bg:"#FFE4E6",color:"#BE123C"},{bg:"#FEF3C7",color:"#92400E"},{bg:"#D1FAE5",color:"#065F46"}],qt=["gold","silver","bronze","plain"],Vt=["1","2","3","4"];function st(t,e){const o=typeof e=="string"?s(e):e;if(o){if(o.innerHTML="",!t.length){o.innerHTML='<div style="font-size:13px;color:var(--color-text-secondary)">No data yet.</div>';return}t.forEach((a,n)=>{const r=(a.name||"C").split(" ").map(m=>m[0]).join("").toUpperCase().slice(0,2),u=bt[n%bt.length],c=qt[Math.min(n,3)],l=Vt[Math.min(n,3)],p=document.createElement("div");p.className="top-customer-row",p.innerHTML=`
      <span class="medal-dot ${c}">${l}</span>
      <span class="customer-avatar" style="background:${u.bg};color:${u.color}">${r}</span>
      <div class="top-customer-info">
        <div class="top-customer-name">${a.name||"Customer"}</div>
        <div class="top-customer-meta">${a.orders||0} orders</div>
      </div>
      <div class="top-customer-spend">${a.spend||""}</div>
    `,o.appendChild(p)})}}function Q(t){V("#booking-status-chips [data-status]").forEach(e=>{e.classList.toggle("active",e.dataset.status===t)})}async function Wt(){const t=await y("/admin/booking-summaries");if(!t.ok)return;const e=t.data?.data||{},o=e.by_status||{},a=e.total??0;V("[data-status-count]").forEach(n=>{const r=n.dataset.statusCount,u=r==="all"?a:o[r]??0;d(n,u)})}function Lt(t,e){const o=Tt(e);return e==="ready"||e==="completed"?(i.bookings.steps[t]=o,o):i.bookings.steps[t]!==void 0?i.bookings.steps[t]:o!==null?(i.bookings.steps[t]=o,o):null}function Yt(t,e){return e===null?"":["Washing","Drying","Ready","Done"].map((a,n)=>`<button class="step-chip ${n===e?"active":""}" data-booking-step="${n}" data-order-id="${t}" type="button">${a}</button>`).join("")}function Kt(t,e){const o=[];return e==="pending"&&(o.push(`<button class="button-outline btn-sm btn-success" data-booking-action="accept" data-order-id="${t}" type="button">Accept</button>`),o.push(`<button class="button-outline btn-sm btn-danger" data-booking-action="decline" data-order-id="${t}" type="button">Decline</button>`)),(e==="ongoing"||e==="ready")&&o.push(`<button class="button-outline btn-sm btn-success" data-booking-action="complete" data-order-id="${t}" type="button">Complete</button>`),o.join("")}function $t(t){const e=String(t),o=i.bookings.byId[e];if(!o)return;i.bookings.activeOrderId=e;const a=s("#booking-modal"),n=s("#booking-modal-overlay"),r=s("#booking-modal-body"),u=s("#booking-modal-title"),c=s("#booking-modal-subtitle"),l=G(o),p=I(o.status)||"pending";u&&(u.textContent="Booking details"),c&&(c.textContent=`${l} · ${p}`),r&&(r.innerHTML=Dt(o)),n&&n.classList.add("show"),a&&(a.classList.add("show"),a.classList.remove("hidden"))}function _t(){i.bookings.activeOrderId=null,s("#booking-modal-overlay")?.classList.remove("show");const t=s("#booking-modal");t&&(t.classList.remove("show"),t.classList.add("hidden"))}function ft(t){const e=t.dataset.orderId,o=t.dataset.bookingAction;o==="accept"?(i.bookings.steps[e]=0,Y(e,"ongoing")):o==="decline"?Y(e,"cancelled"):o==="complete"&&(i.bookings.steps[e]=3,Y(e,"completed"))}function vt(t){const e=t.dataset.orderId,o=Number(t.dataset.bookingStep);Number.isNaN(o)||(i.bookings.steps[e]=o,Y(e,At(o)))}async function j(){const t=Wt(),e=s("#bookings-filter");e&&(e.value=i.bookings.status);const o=new URLSearchParams({page:i.bookings.page.toString(),per_page:i.bookings.perPage.toString()});i.bookings.status&&i.bookings.status!=="all"&&o.set("status",i.bookings.status);const a=await y(`/admin/orders?${o.toString()}`),n=s("#bookings-table-body");if(!n)return;if(n.innerHTML="",!a.ok){n.innerHTML='<tr><td colspan="8">Unable to load bookings.</td></tr>';return}const r=a.data?.data||[],u=a.data?.pagination||{};if(i.bookings.byId={},!r.length){n.innerHTML='<tr><td colspan="8">No bookings found.</td></tr>',await t,Q(i.bookings.status);return}r.forEach(g=>{const $=g.order_id||g.id,x=String($);i.bookings.byId[x]=g;const b=I(g.status);Lt($,b);const w=document.createElement("tr"),S=(g.customer_name||"Customer").split(" ").map(N=>N[0]).join("").substring(0,2).toUpperCase(),C=E(g.created_at),D=G(g),M=[{bg:"#EEEDFE",color:"#3C3489"},{bg:"#E1F5EE",color:"#085041"},{bg:"#E6F1FB",color:"#0C447C"}],F=M[(g.customer_id||0)%M.length];w.innerHTML=`
      <td><span class="order-id">${D}</span></td>
      <td>
        <div class="order-customer-cell">
          <span class="order-customer-avatar" style="background:${F.bg};color:${F.color}">${S}</span>
          <span class="order-customer-name">${g.customer_name||"Unknown"}</span>
        </div>
      </td>
      <td>${g.service_type||"Service"}</td>
      <td>${g.weight_kg||0} kg</td>
      <td>${L(g.total_price||0)}</td>
      <td>
        <span class="status-pill" data-status="${b}">
          <span class="status-dot"></span>
          ${b}
        </span>
      </td>
      <td><span class="order-created-date">${C}</span></td>
      <td>
        <div style="display:flex; gap:6px; align-items:center;">
          <button class="btn-action-pill btn-action-details" data-booking-toggle="${$}" type="button">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            Details
          </button>
          <button class="btn-action-pill btn-action-receipt" data-cod-receipt-id="${$}" type="button">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
            Receipt
          </button>
        </div>
      </td>
    `,n.appendChild(w)});const c=u.total||r.length;d("#bookings-footer-info",`Showing ${r.length} of ${c} orders — Page ${u.current_page||1} of ${u.last_page||1}`);const l=s("#bookings-prev"),p=s("#bookings-next"),m=s("#bookings-current-page");l&&(l.disabled=(u.current_page||1)<=1),p&&(p.disabled=(u.current_page||1)>=(u.last_page||1)),m&&(m.textContent=u.current_page||1),await t,Q(i.bookings.status)}async function Y(t,e){const o=String(t),a=await y(`/admin/orders/${t}/status`,{method:"PATCH",body:{status:e}});if(!a.ok){h("Unable to update status.");return}h("Order status updated.");const n=a.data?.data;await j(),n&&(i.bookings.byId[o]=n),i.bookings.activeOrderId===o&&$t(t)}async function K(){const t=new URLSearchParams({page:i.customers.page.toString(),per_page:i.customers.perPage.toString()});i.customers.search&&t.set("search",i.customers.search);const e=await y(`/admin/customers?${t.toString()}`),o=s("#customers-table-body");if(!o)return;if(o.innerHTML="",!e.ok){o.innerHTML='<tr><td colspan="6">Unable to load customers.</td></tr>';return}const a=e.data?.data||[],n=e.data?.pagination||{};a.length||(o.innerHTML='<tr><td colspan="6">No customers found.</td></tr>'),a.forEach(c=>{const l=document.createElement("tr");l.innerHTML=`
      <td>
        <div class="font-semibold">${c.name||"Customer"}</div>
        <div class="text-xs text-slate-500">${c.email||""}</div>
      </td>
      <td>${c.phone||"---"}</td>
      <td>${c.orders_count||0}</td>
      <td>${L(c.total_spent||0)}</td>
      <td>${c.loyalty_points||0}</td>
      <td>
        <button class="button-outline" data-customer-id="${c.id}">View</button>
      </td>
    `,o.appendChild(l)}),d("#customers-page-info",`Page ${n.current_page||1} of ${n.last_page||1}`);const r=s("#customers-prev"),u=s("#customers-next");r&&(r.disabled=(n.current_page||1)<=1),u&&(u.disabled=(n.current_page||1)>=(n.last_page||1))}async function Gt(t){i.currentCustomerId=t,s("#customer-drawer")?.classList.add("open"),s("#drawer-overlay")?.classList.add("show"),d("#customer-drawer-title","Loading...");const e=await y(`/admin/customers/${t}`);if(!e.ok){h("Unable to load customer.");return}const o=e.data?.data||{};d("#customer-drawer-title",o.name||"Customer"),s("#customer-name").value=o.name||"",s("#customer-email").value=o.email||"",s("#customer-phone").value=o.phone||"",s("#customer-address").value=o.address||"",s("#customer-city").value=o.city||"",s("#customer-zip").value=o.zip_code||"",s("#customer-country").value=o.country||"",s("#customer-notifications").checked=o.notifications_enabled!==!1,d("#customer-loyalty",o.loyalty_points||0),d("#customer-orders-count",o.orders_count||0),d("#customer-total-spent",L(o.total_spent||0)),d("#customer-dob",z(E(o.date_of_birth))),d("#customer-gender",z(o.gender)),d("#customer-language",z(o.preferred_language)),d("#customer-email-verified",ut(!!o.email_verified_at)),d("#customer-profile-completed",ut(!!o.profile_completed_at)),d("#customer-member-since",z(E(o.created_at))),d("#customer-last-login",z(E(o.last_login_at))),d("#customer-bio",z(o.bio)),i.customerOrders.page=1,i.customerOrders.lastPage=1,await Ct(!0)}function ht(){s("#customer-drawer")?.classList.remove("open"),s("#drawer-overlay")?.classList.remove("show"),i.currentCustomerId=null}async function Jt(){if(!i.currentCustomerId)return;const t={name:s("#customer-name").value.trim(),phone:s("#customer-phone").value.trim()||null,address:s("#customer-address").value.trim()||null,city:s("#customer-city").value.trim()||null,zip_code:s("#customer-zip").value.trim()||null,country:s("#customer-country").value.trim()||null,notifications_enabled:s("#customer-notifications").checked};if(!(await y(`/admin/customers/${i.currentCustomerId}`,{method:"PUT",body:t})).ok){h("Unable to update customer.");return}h("Customer updated."),await K()}async function Ct(t=!1){if(!i.currentCustomerId)return;t&&(i.customerOrders.page=1);const e=new URLSearchParams({page:i.customerOrders.page.toString(),per_page:i.customerOrders.perPage.toString()}),o=await y(`/admin/customers/${i.currentCustomerId}/orders?${e.toString()}`),a=s("#customer-orders-body");if(!a)return;if(!o.ok){t&&(a.innerHTML='<tr><td colspan="5">Unable to load orders.</td></tr>');return}const n=o.data?.data||[],r=o.data?.pagination||{};t&&(a.innerHTML=""),!n.length&&t&&(a.innerHTML='<tr><td colspan="5">No orders yet.</td></tr>'),n.forEach(p=>{const m=document.createElement("tr");m.innerHTML=`
      <td>${p.id||""}</td>
      <td>${p.service_type||""}</td>
      <td>${p.weight_kg||0} kg</td>
      <td>${L(p.total_price||0)}</td>
      <td>${p.status||""}</td>
    `,a.appendChild(m)}),i.customerOrders.lastPage=r.last_page||1;const u=r.current_page||i.customerOrders.page;d("#customer-orders-page-info",`Page ${u} of ${i.customerOrders.lastPage}`);const c=Number.isFinite(r.total)?r.total:n.length;d("#customer-orders-title-count",`(${c})`);const l=s("#customer-orders-load");if(l){const p=u>=i.customerOrders.lastPage;l.disabled=p,l.classList.toggle("hidden",p||c===0)}}async function Zt(){const t=await y("/admin/analytics");if(!t.ok){h("Unable to load analytics.");return}const e=t.data||{},o=Number(e.monthly_revenue||0),a=Number(e.total_orders_this_month||0),n=Number(e.completed_orders_this_month||0),r=Number(e.cancelled_orders_this_month||0),u=Number(e.new_customers_this_month||0),c=Number(e.total_customers||0),l=Number(e.completion_rate||0),p=e.top_service||null,m=Array.isArray(e.top_customers)?e.top_customers:[],g=m[0]||null;d("#analytics-month",e.month_label||""),d("#analytics-monthly-revenue",L(o)),d("#analytics-monthly-card",L(o)),d("#analytics-completion-rate",`${l}%`),d("#analytics-monthly-orders",a),d("#analytics-new-customers",u),d("#analytics-total-customers",`${c} total customers`),d("#analytics-completed-orders",n),d("#analytics-cancelled-orders",`${r} cancelled`),d("#analytics-top-service",p?.name||"No service data yet"),d("#analytics-top-service-meta",p?`${p.orders||0} orders`:"No completed order mix yet"),d("#analytics-top-customer",g?.name||"No customer data yet"),d("#analytics-top-customer-meta",g?`${g.orders||0} orders · ${g.spend_label||L(g.spend||0)}`:"No customer orders yet"),d("#analytics-order-health",`${l}% completion`);const $=e.weekly_revenue||[],x=Math.max(1,...$.map(v=>Number(v||0))),b=["Mon","Tue","Wed","Thu","Fri","Sat","Sun"],w=s("#weekly-bars");w.innerHTML="",$.forEach((v,O)=>{const _=Math.round(Number(v||0)/x*100),T=document.createElement("div");T.className="weekly-bar",T.innerHTML=`
      <div class="weekly-bar-value">${L(Number(v||0))}</div>
      <div class="weekly-bar-track" title="${L(Number(v||0))}">
        <div class="weekly-bar-fill" style="height:${_}%;"></div>
      </div>
      <div class="weekly-bar-label">${b[O]||""}</div>
    `,w.appendChild(T)});const S=e.service_breakdown||[],C=s("#service-breakdown-body"),D=s("#service-breakdown-donut"),M=s("#service-breakdown-total");C&&(C.innerHTML="");const F=["#3B82F6","#34D399","#F59E0B","#EC4899","#A78BFA","#22D3EE"];let N=0,H=0;const B=[];if(!S.length)C&&(C.innerHTML='<div class="analytics-empty">No service data yet.</div>'),D&&(D.style.background="conic-gradient(rgba(148, 163, 184, 0.2) 0% 100%)"),M&&d("#service-breakdown-total","0%");else if(S.forEach((v,O)=>{const _=Math.max(0,Math.min(100,Number(v.pct||0))),T=F[O%F.length];if(_>0&&B.push(`${T} ${N}% ${N+_}%`),N+=_,H+=_,C){const U=document.createElement("div");U.className="breakdown-legend-row",U.innerHTML=`
          <span class="breakdown-legend-swatch" style="background:${T};"></span>
          <div class="breakdown-legend-copy">
            <div class="breakdown-legend-name">${A(v.name||"Service")}</div>
            <div class="breakdown-legend-meta">${_}% &middot; ${v.count||0} orders</div>
          </div>
        `,C.appendChild(U)}}),D){const v=Math.min(100,Math.round(H));H<100&&B.push(`rgba(148, 163, 184, 0.2) ${H}% 100%`),D.style.background=`conic-gradient(${B.join(", ")})`,M&&d("#service-breakdown-total",`${v}%`)}const R=s("#analytics-top-customers-list");R&&(R.innerHTML="",m.length?m.forEach((v,O)=>{const _=document.createElement("div");_.className="analytics-customer-row",_.innerHTML=`
          <span class="analytics-rank">${O+1}</span>
          <div class="analytics-customer-copy">
            <strong>${A(v.name||"Customer")}</strong>
            <span>${v.orders||0} orders</span>
          </div>
          <div class="analytics-customer-spend">${v.spend_label||L(v.spend||0)}</div>
        `,R.appendChild(_)}):R.innerHTML='<div class="analytics-empty">No customer spend data yet.</div>')}async function nt(){const[t,e]=await Promise.all([y("/admin/services"),y("/admin/top-customers")]),o=s("#services-table-body");if(!o)return;if(o.innerHTML="",!t.ok){o.innerHTML='<tr><td colspan="6">Unable to load services.</td></tr>',st(e.ok?e.data?.data||[]:[],"#services-top-customers-body");return}const a=t.data?.data||[];a.length||(o.innerHTML='<tr><td colspan="6">No services found.</td></tr>'),a.forEach(n=>{const r=document.createElement("tr");r.innerHTML=`
      <td>
        <div class="font-semibold">${n.name||"Service"}</div>
        <div class="text-xs text-slate-500">${n.description||""}</div>
      </td>
      <td>${L(n.price_per_kg||0)}</td>
      <td>${n.category||"---"}</td>
      <td>${n.is_active?"Active":"Inactive"}</td>
      <td class="space-x-2">
        <button class="button-outline" data-edit-service="${n.id}">Edit</button>
        <button class="button-outline" data-delete-service="${n.id}">Delete</button>
      </td>
    `,o.appendChild(r)}),st(e.ok?e.data?.data||[]:[],"#services-top-customers-body")}async function Qt(){const t={name:s("#service-name").value.trim(),description:s("#service-description").value.trim()||null,price_per_kg:Number(s("#service-price").value||0),category:s("#service-category").value.trim()||null,image_url:s("#service-image").value.trim()||null,is_active:s("#service-active").checked},e=i.services.editingId;if(!(await y(`/admin/services${e?`/${e}`:""}`,{method:e?"PUT":"POST",body:t})).ok){h("Unable to save service.");return}h(e?"Service updated.":"Service created."),Et(),await nt()}function Et(){i.services.editingId=null,d("#service-form-title","Create service"),s("#service-name").value="",s("#service-description").value="",s("#service-price").value="",s("#service-category").value="",s("#service-image").value="",s("#service-active").checked=!0}async function Xt(t){const e=await y("/admin/services");if(!e.ok)return;const a=(e.data?.data||[]).find(n=>n.id===Number(t));a&&(i.services.editingId=a.id,d("#service-form-title","Update service"),s("#service-name").value=a.name||"",s("#service-description").value=a.description||"",s("#service-price").value=a.price_per_kg||"",s("#service-category").value=a.category||"",s("#service-image").value=a.image_url||"",s("#service-active").checked=a.is_active!==!1)}async function te(t){if(!window.confirm("Delete this service?"))return;if(!(await y(`/admin/services/${t}`,{method:"DELETE"})).ok){h("Unable to delete service.");return}h("Service deleted."),await nt()}function yt(t,e,o){t.type=o?"text":"password",e.setAttribute("aria-pressed",o?"true":"false"),e.setAttribute("aria-label",o?"Hide password":"Show password"),e.innerHTML=o?'<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>':'<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>'}function ee(){const t=s("#login-form");t&&t.addEventListener("submit",It);const e=s("#toggle-password"),o=s("#login-password");e&&o&&(yt(o,e,!1),e.addEventListener("click",()=>{const f=o.type==="password";yt(o,e,f)}));const a=s("#logout-button");a&&a.addEventListener("click",Ht);const n=s("#logout-modal-cancel");n&&n.addEventListener("click",mt);const r=s("#logout-modal-confirm");r&&r.addEventListener("click",zt);const u=s("#logout-modal-overlay");u&&u.addEventListener("click",mt),V("[data-view]").forEach(f=>{f.addEventListener("click",()=>{ot(f.dataset.view),pt()})});const c=s("#bookings-filter");c&&c.addEventListener("change",f=>{i.bookings.status=f.target.value,i.bookings.page=1,Q(i.bookings.status),j()});const l=s("#booking-status-chips");l&&l.addEventListener("click",f=>{const k=f.target.closest("[data-status]");k&&(i.bookings.status=k.dataset.status,i.bookings.page=1,Q(i.bookings.status),c&&(c.value=i.bookings.status),j())});const p=s("#bookings-prev");p&&p.addEventListener("click",()=>{i.bookings.page=Math.max(1,i.bookings.page-1),j()});const m=s("#bookings-next");m&&m.addEventListener("click",()=>{i.bookings.page+=1,j()});const g=s("#bookings-table-body");g&&(g.addEventListener("change",f=>{const k=f.target.closest("select[data-order-id]");k&&Y(k.dataset.orderId,k.value)}),g.addEventListener("click",f=>{const k=f.target.closest("[data-cod-receipt-id]");if(k){const X=k.dataset.codReceiptId,lt=i.bookings.byId[String(X)];lt?oe(lt):h("Receipt data unavailable. Please refresh.");return}const P=f.target.closest("[data-booking-toggle]");if(P){const X=P.dataset.bookingToggle;$t(X);return}const dt=f.target.closest("[data-booking-action]");if(dt){ft(dt);return}const ct=f.target.closest("[data-booking-step]");ct&&vt(ct)}));const $=s("#booking-modal-close");$&&$.addEventListener("click",_t);const x=s("#booking-modal");x&&x.addEventListener("click",f=>{const k=f.target.closest("[data-booking-action]");if(k){ft(k);return}const P=f.target.closest("[data-booking-step]");P&&vt(P)});const b=s("#customers-search-button");b&&b.addEventListener("click",()=>{i.customers.search=s("#customers-search-input").value.trim(),i.customers.page=1,K()});const w=s("#customers-prev");w&&w.addEventListener("click",()=>{i.customers.page=Math.max(1,i.customers.page-1),K()});const S=s("#customers-next");S&&S.addEventListener("click",()=>{i.customers.page+=1,K()});const C=s("#customers-table-body");C&&C.addEventListener("click",f=>{const k=f.target.closest("[data-customer-id]");k&&Gt(k.dataset.customerId)});const D=s("#customer-drawer-close");D&&D.addEventListener("click",ht);const M=s("#drawer-overlay");M&&M.addEventListener("click",ht);const F=s("#customer-save");F&&F.addEventListener("click",Jt);const N=s("#customer-orders-load");N&&N.addEventListener("click",()=>{i.customerOrders.page>=i.customerOrders.lastPage||(i.customerOrders.page+=1,Ct())});const H=s("#service-save");H&&H.addEventListener("click",Qt);const B=s("#service-clear");B&&B.addEventListener("click",Et);const R=s("#services-table-body");R&&R.addEventListener("click",f=>{const k=f.target.closest("[data-edit-service]");if(k){Xt(k.dataset.editService);return}const P=f.target.closest("[data-delete-service]");P&&te(P.dataset.deleteService)});const v=s("#recent-orders-view-all");v&&v.addEventListener("click",()=>ot("bookings"));const O=s("#sidebar-toggle");O&&O.addEventListener("click",Ot);const _=s("#sidebar-overlay");_&&_.addEventListener("click",pt);const T=s("#cod-receipt-close");T&&T.addEventListener("click",tt);const U=s("#cod-receipt-cancel");U&&U.addEventListener("click",tt);const it=s("#cod-receipt-print");it&&it.addEventListener("click",se);const rt=s("#cod-receipt-overlay");rt&&rt.addEventListener("click",tt)}window.addEventListener("DOMContentLoaded",()=>{ee(),Pt()});function oe(t){const e=s("#cod-receipt-modal"),o=s("#cod-receipt-overlay"),a=s("#cod-receipt-body");if(!e||!o||!a)return;const n=G(t),r=kt(t.delivery_type),u=E(t.pickup_date),c=E(t.delivery_date),l=E(t.created_at),p=L(t.total_price||0),m=new Date().toLocaleDateString("en-PH",{month:"short",day:"numeric",year:"numeric"}),g=($,x,b="")=>`
    <tr>
      <td style="padding:9px 12px; color:#58708D; font-size:12px; font-weight:500; width:42%; white-space:nowrap; vertical-align:middle;">
        ${b?`<span style="margin-right:5px; opacity:0.7;">${b}</span>`:""}${$}
      </td>
      <td style="padding:9px 12px; color:#08213D; font-size:12.5px; font-weight:600; vertical-align:middle;">${x}</td>
    </tr>`;a.innerHTML=`
    <div id="cod-receipt-print-area" style="font-family:'Segoe UI',Arial,sans-serif; color:#08213D; background:#fff;">

      <!-- Branded Header -->
      <div style="background:linear-gradient(135deg,#1565C0 0%,#0D47A1 100%); padding:22px 24px 20px; text-align:center; position:relative; overflow:hidden;">
        <div style="position:absolute;top:-18px;right:-18px;width:90px;height:90px;border-radius:50%;background:rgba(255,255,255,0.07);"></div>
        <div style="position:absolute;bottom:-24px;left:-12px;width:70px;height:70px;border-radius:50%;background:rgba(255,255,255,0.05);"></div>
        <div style="font-size:10px; font-weight:800; letter-spacing:0.22em; text-transform:uppercase; color:rgba(255,255,255,0.65); margin-bottom:6px;">LaundryHub</div>
        <div style="font-size:24px; font-weight:800; color:#fff; letter-spacing:-0.5px; margin-bottom:4px;">Cash on Delivery Receipt</div>
        <div style="display:inline-block; background:rgba(255,255,255,0.15); border-radius:20px; padding:3px 14px; font-size:12px; font-weight:700; color:#fff; letter-spacing:0.05em;">${n}</div>
        <div style="margin-top:6px; font-size:11px; color:rgba(255,255,255,0.55);">Issued: ${m}</div>
      </div>

      <!-- Detail Rows -->
      <div style="padding:4px 0;">
        <table style="width:100%; border-collapse:collapse;">
          <tbody>
            <tr style="background:#F8FBFF;">
              <td colspan="2" style="padding:7px 12px; font-size:10px; font-weight:800; letter-spacing:0.12em; text-transform:uppercase; color:#58708D;">Customer Info</td>
            </tr>
            ${g("Customer",A(t.customer_name||"N/A"),"👤")}
            ${g("Address",A(t.pickup_address||"N/A"),"📍")}
            <tr style="background:#F8FBFF;">
              <td colspan="2" style="padding:7px 12px; font-size:10px; font-weight:800; letter-spacing:0.12em; text-transform:uppercase; color:#58708D;">Order Details</td>
            </tr>
            ${g("Service",A(t.service_type||"---"),"🧺")}
            ${g("Weight",`${t.weight_kg||0} kg`,"⚖️")}
            ${g("Fulfillment",r,"🚚")}
            ${g("Pickup Date",u,"📅")}
            ${g("Delivery Date",c,"📅")}
            ${g("Order Date",l,"🗓️")}
          </tbody>
        </table>
      </div>

      <!-- Total Banner -->
      <div style="margin:0 16px 16px; background:linear-gradient(135deg,#EEF4FF 0%,#E8F0FE 100%); border:1px solid rgba(21,101,192,0.18); border-radius:10px; padding:16px 20px; display:flex; align-items:center; justify-content:space-between;">
        <div>
          <div style="font-size:10px; font-weight:700; letter-spacing:0.10em; text-transform:uppercase; color:#58708D; margin-bottom:2px;">Total Amount Due</div>
          <div style="font-size:26px; font-weight:800; color:#1565C0; letter-spacing:-0.5px;">${p}</div>
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
  `,e.classList.remove("hidden"),e.classList.add("show"),o.classList.add("show")}function tt(){const t=s("#cod-receipt-modal"),e=s("#cod-receipt-overlay");t&&(t.classList.remove("show"),t.classList.add("hidden")),e&&e.classList.remove("show")}function se(){const t=s("#cod-receipt-modal");if(!t||t.classList.contains("hidden")){h("Open a receipt first.");return}const e=Array.from(t.querySelectorAll("#cod-receipt-print-area table tbody tr")).filter(b=>!b.querySelector("[colspan]")).map(b=>{const w=b.querySelectorAll("td");if(w.length<2)return null;const S=w[0].textContent.replace(/[\u{1F000}-\u{1FFFF}]/gu,"").trim(),C=w[1].textContent.trim();return{label:S,value:C}}).filter(Boolean);t.querySelector(".btn-action-receipt")?.dataset?.codReceiptId;const o=t.querySelector("#cod-receipt-print-area > div:first-child"),a=o?o.querySelectorAll("div"):[],n=a[2]?.textContent?.trim()||"",r=a[3]?.textContent?.trim()||"",c=t.querySelector('#cod-receipt-print-area [style*="font-size:26px"]')?.textContent?.trim()||"";e.map(({label:b,value:w})=>`
    <tr>
      <td class="label-col">${b}</td>
      <td class="value-col">${w}</td>
    </tr>`).join("");const l=["Customer","Address"],p=e.filter(b=>l.includes(b.label)),m=e.filter(b=>!l.includes(b.label)),g=b=>b.map(({label:w,value:S})=>`
    <tr>
      <td class="label">${w}</td>
      <td class="value">${S}</td>
    </tr>`).join(""),$=`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>COD Receipt ${n}</title>
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
      <div class="order-pill">${n}</div>
      <div class="issued">${r}</div>
    </div>

    <div class="section">
      <div class="section-head">Customer Information</div>
      <table>
        ${g(p)}
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
</html>`,x=window.open("","_blank","width=680,height=860");if(!x){h("Allow pop-ups to print/save this receipt.");return}x.document.open(),x.document.write($),x.document.close(),x.onload=()=>{x.focus(),x.print()}}function ae(){const t=document.getElementById("report-filter")?.value||"all";let e=Object.values(i.bookings.byId||{});if(t!=="all"&&(e=e.filter(l=>I(l.status)===t)),!e.length){h("No orders available to export for the selected filter.");return}const o=["Order ID","Customer","Service","Weight (kg)","Total Price","Status","Date"],a=e.map(l=>[G(l),`"${A(l.customer_name||"N/A")}"`,`"${A(l.service_type||"N/A")}"`,l.weight_kg||0,l.total_price||0,I(l.status),E(l.created_at)]),n=[o.join(","),...a.map(l=>l.join(","))].join(`
`),r=new Blob([n],{type:"text/csv;charset=utf-8;"}),u=URL.createObjectURL(r),c=document.createElement("a");c.href=u,c.setAttribute("download",`LaundryHub_Orders_Report_${new Date().toISOString().split("T")[0]}.csv`),document.body.appendChild(c),c.click(),document.body.removeChild(c)}function ne(){const t=document.getElementById("report-filter")?.value||"all";let e=Object.values(i.bookings.byId||{});if(t!=="all"&&(e=e.filter(n=>I(n.status)===t)),!e.length){h("No orders available to export for the selected filter.");return}const o=window.open("","_blank","width=800,height=900");if(!o){h("Please allow pop-ups to generate PDF report.");return}const a=e.map(n=>`
    <tr>
      <td>${G(n)}</td>
      <td>${A(n.customer_name||"N/A")}</td>
      <td>${A(n.service_type||"N/A")}</td>
      <td>${n.weight_kg||0}kg</td>
      <td>${L(n.total_price||0)}</td>
      <td><span style="text-transform:capitalize;">${I(n.status)}</span></td>
    </tr>
  `).join("");o.document.write(`
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
            ${a}
          </tbody>
        </table>
      </body>
    </html>
  `),o.document.close(),o.onload=()=>{o.focus(),o.print()}}document.addEventListener("DOMContentLoaded",()=>{const t=document.getElementById("btn-download-csv"),e=document.getElementById("btn-download-pdf");t&&t.addEventListener("click",ae),e&&e.addEventListener("click",ne)});
