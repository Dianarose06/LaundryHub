import"./app-UyRVujZY.js";const n={token:null,user:null,isLoginSubmitting:!1,isLogoutSubmitting:!1,view:"dashboard",bookings:{page:1,perPage:20,status:"all",steps:{},byId:{},activeOrderId:null},customers:{page:1,perPage:20,search:""},services:{editingId:null},customerOrders:{page:1,perPage:10,lastPage:1},currentCustomerId:null},s=(t,e=document)=>e.querySelector(t),j=(t,e=document)=>Array.from(e.querySelectorAll(t)),St=`${window.LAUNDRYHUB_API_BASE_URL||"/api"}`.replace(/\/$/,"");function c(t,e){const o=typeof t=="string"?s(t):t;o&&(o.textContent=e)}function z(t){t&&t.classList.remove("hidden")}function K(t){t&&t.classList.add("hidden")}function h(t){const e=s("#toast");e&&(e.textContent=t,e.classList.add("show"),e.setAttribute("aria-hidden","false"),setTimeout(()=>{e.classList.remove("show"),e.setAttribute("aria-hidden","true")},3e3))}function w(t){return`PHP ${Number(t||0).toLocaleString("en-PH",{maximumFractionDigits:0})}`}function $(t){if(!t)return"---";const e=new Date(t);return Number.isNaN(e.getTime())?t:e.toLocaleDateString("en-PH",{month:"short",day:"numeric",year:"numeric"})}function I(t,e="---"){return t==null||t===""?e:t}function q(t){return`${t??""}`.replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;").replaceAll('"',"&quot;").replaceAll("'","&#039;")}function ut(t){return t?"Yes":"No"}function tt(t){return`${t||""}`.trim().toLowerCase()}function Z(t){return(t||"").toString().toLowerCase()}function kt(t){return(Z(t)||"pickup")==="delivery"?"Delivery":"Pickup"}function ot(t){const e=t?.id??t?.order_id??"",o=String(e).replace(new RegExp("^#?LH-+"),"");return o?`#LH-${o.padStart(3,"0")}`:String(e||"---")}function Tt(t){const e=t.order_id||t.id,o=Z(t.status),a=$t(e,o),i=$(t.pickup_date),r=$(t.delivery_date||t.pickup_date),d=kt(t.delivery_type),l=I(t.pickup_address),p=$(t.updated_at),u=["ongoing","ready","completed"].includes(o)?Yt(e,a):"",g=Jt(e,o);return`
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
        <div class="details-value">${$(t.created_at)}</div>
      </div>
      <div>
        <div class="details-label">Updated</div>
        <div class="details-value">${p}</div>
      </div>
    </div>
    <div class="details-actions">
      ${u?`<div class="step-chips">${u}</div>`:"<div></div>"}
      <div class="action-buttons">${g||'<span class="text-xs text-muted">No actions</span>'}</div>
    </div>
  `}function Mt(t){return t==="ready"?2:t==="completed"?3:t==="ongoing"?0:null}function At(t){return t===2?"ready":t===3?"completed":"ongoing"}function et(t){n.view=t,j(".view-section").forEach(e=>{e.classList.toggle("hidden",e.dataset.view!==t)}),j("[data-view]").forEach(e=>{e.classList.toggle("active",e.dataset.view===t)}),Ut(t).catch(e=>{console.error("Failed to load view",e)})}function wt(t,e){localStorage.setItem("lh_admin_token",t),localStorage.setItem("lh_admin_user",JSON.stringify(e)),n.token=t,n.user=e}function V(){localStorage.removeItem("lh_admin_token"),localStorage.removeItem("lh_admin_user"),n.token=null,n.user=null}function Lt(){return window.location.pathname==="/admin"}function Dt(){return window.location.pathname.startsWith("/admin/dashboard")}function J(){if(xt(),!Lt()){window.location.assign("/admin");return}z(s(".bg-aurora")),z(s("#login-view")),K(s("#app-view"))}function Nt(){if(!Dt()){window.location.assign("/admin/dashboard");return}if(K(s(".bg-aurora")),K(s("#login-view")),z(s("#app-view")),Pt(),n.user){const t=n.user.name?.trim()||"LaundryHub Admin",e="Admin",o=e.charAt(0).toUpperCase()||"A",a=n.user.email||"admin@laundryhub.com";c("#user-name",t),c("#user-email",n.user.email||""),c("#header-admin-name",e),c("#header-admin-avatar",o),c("#sidebar-admin-name",e),c("#sidebar-admin-email",a),c("#sidebar-admin-avatar",o)}}function Pt(){const t=s("#app-view");if(!t||t.classList.contains("hidden"))return;const e=[".sidebar",".mobile-topbar","#login-view",".drawer",".modal"];j("body *").forEach(a=>{if(!(a instanceof HTMLElement)||a.id==="app-view"||a.id==="login-view"||e.some(g=>a.closest(g)))return;const i=a.getBoundingClientRect();if(i.width<320||i.height<320)return;const r=window.getComputedStyle(a);if(!(["fixed","absolute"].includes(r.position)||r.pointerEvents==="none"||Number(r.opacity||"1")<.35))return;const l=`${a.className||""}`.toLowerCase(),p=`${a.id||""}`.toLowerCase();(l.includes("watermark")||l.includes("logo")||l.includes("aurora")||l.includes("bg-")||p.includes("watermark")||p.includes("logo")||r.zIndex==="0"&&r.pointerEvents==="none")&&(a.style.display="none")})}function pt(){s(".sidebar")?.classList.remove("open"),s("#sidebar-overlay")?.classList.remove("show"),s("#sidebar-toggle")?.setAttribute("aria-expanded","false")}function Ot(){const t=s(".sidebar"),e=s("#sidebar-overlay"),o=s("#sidebar-toggle");if(!t||!e||!o)return;const a=t.classList.toggle("open");e.classList.toggle("show",a),o.setAttribute("aria-expanded",a?"true":"false")}function mt(t){const e=s("#login-submit"),o=s("#login-submit .btn-spinner"),a=s("#login-submit .btn-label"),i=s("#login-email"),r=s("#login-password");e&&(e.disabled=t,e.classList.toggle("is-loading",t),e.setAttribute("aria-busy",t?"true":"false")),o&&o.classList.toggle("hidden",!t),a&&(a.textContent=t?"Signing in...":"Sign in"),i&&(i.disabled=t),r&&(r.disabled=t)}function at(t){const e=s("#logout-modal-confirm"),o=s("#logout-modal-confirm .btn-spinner"),a=s("#logout-modal-confirm .btn-label"),i=s("#logout-modal-cancel");e&&(e.disabled=t,e.classList.toggle("is-loading",t),e.setAttribute("aria-busy",t?"true":"false")),o&&o.classList.toggle("hidden",!t),a&&(a.textContent=t?"Logging out...":"Yes"),i&&(i.disabled=t)}async function f(t,e={}){const o=new AbortController,a=Number.isFinite(e.timeoutMs)?e.timeoutMs:2e4,i=a>0?setTimeout(()=>o.abort(),a):null,r={method:e.method||"GET",headers:{Accept:"application/json",...e.headers},signal:o.signal};!e.skipAuth&&n.token&&(r.headers.Authorization=`Bearer ${n.token}`),e.body&&(r.headers["Content-Type"]="application/json",r.body=JSON.stringify(e.body));try{const d=await fetch(`${St}${t}`,r);i&&clearTimeout(i);let l=null;try{l=await d.json()}catch{l=null}return(d.status===401||d.status===403)&&(V(),J(),h("Session expired. Please sign in again.")),{ok:d.ok,status:d.status,data:l}}catch(d){return i&&clearTimeout(i),d?.name==="AbortError"?(h("Request timed out. The server may still be starting up."),{ok:!1,status:408,data:{message:"Request timed out."}}):(h("Network error. Please try again."),{ok:!1,status:0,data:null})}}async function Ht(){const t=Lt(),e=localStorage.getItem("lh_admin_token"),o=localStorage.getItem("lh_admin_user");if(!e||!o){V(),J();return}let a=null;try{a=JSON.parse(o)}catch{V(),J();return}if(!a||tt(a.role)!=="admin"){V(),J();return}if(t){window.location.assign("/admin/dashboard");return}n.token=e,n.user=a,Nt(),et("dashboard");const i=await f("/user");i.ok&&tt(i.data?.role)==="admin"&&wt(e,i.data)}async function It(t){if(t.preventDefault(),n.isLoginSubmitting)return;const e=s("#login-email")?.value.trim()||"",o=s("#login-password")?.value||"",a=s("#login-error");K(a),n.isLoginSubmitting=!0,mt(!0);let i=!1,r;try{if(r=await f("/login",{method:"POST",body:{email:e,password:o},skipAuth:!0,timeoutMs:45e3}),!r.ok){c(a,r.data?.message||"Login failed."),z(a);return}const d=r.data?.user||r.data?.data?.user||null,l=`${r.data?.token||r.data?.access_token||r.data?.data?.token||r.data?.data?.access_token||""}`.trim(),p=tt(d?.role);if(!l){c(a,"Login failed. Missing access token."),z(a);return}if(p!=="admin"){c(a,"This account does not have admin access."),z(a);return}wt(l,d),i=!0,window.location.assign("/admin/dashboard")}finally{n.isLoginSubmitting=!1,i||mt(!1)}}async function Rt(){Bt()}function Bt(){n.isLogoutSubmitting||(at(!1),s("#logout-modal-overlay")?.classList.add("show"),s("#logout-modal")?.classList.remove("hidden"),s("#logout-modal")?.classList.add("show"))}function gt(){n.isLogoutSubmitting||(at(!1),s("#logout-modal-overlay")?.classList.remove("show"),s("#logout-modal")?.classList.remove("show"),s("#logout-modal")?.classList.add("hidden"))}async function Ft(){if(!n.isLogoutSubmitting){n.isLogoutSubmitting=!0,at(!0);try{n.token&&await f("/logout",{method:"POST"})}catch{}finally{V(),window.location.assign("/admin")}}}async function Ut(t){t==="dashboard"?await zt():t==="bookings"?await U():t==="customers"?await Y():t==="analytics"?await Zt():t==="services"&&await nt()}async function zt(){c("#stat-total-bookings","--"),c("#stat-pending","--"),c("#stat-revenue","--"),c("#stat-customers","--");const[t,e,o]=await Promise.all([f("/admin/stats"),f("/admin/orders/recent"),f("/admin/top-customers")]);if(t.ok&&t.data){const a=t.data.total_bookings??0,i=t.data.pending_count??0,r=t.data.revenue_today??0,d=t.data.customer_count??0;c("#stat-total-bookings",a),c("#stat-pending",i),c("#stat-revenue",w(r)),c("#stat-customers",d);const l=s("#stat-badge-total");l&&(l.className="stat-badge green",l.textContent="All time");const p=s("#stat-badge-pending");p&&(i>0?(p.className="stat-badge amber",p.textContent="Needs action"):(p.className="stat-badge green",p.textContent="All clear"));const u=s("#stat-badge-revenue");u&&(r>0?(u.className="stat-badge green",u.textContent="Earning today"):(u.className="stat-badge red",u.textContent="No revenue yet"));const g=s("#stat-badge-customers");g&&(g.className="stat-badge green",g.textContent="Growing")}jt(e.ok?e.data?.data||[]:[]),st(o.ok?o.data?.data||[]:[],"#top-customers-body")}function jt(t){const e=s("#recent-orders-body");if(e){if(e.innerHTML="",!t.length){e.innerHTML='<tr><td colspan="5">No recent orders.</td></tr>';return}t.forEach(o=>{const a=document.createElement("tr"),i=(o.status||"").toString().toLowerCase();a.innerHTML=`
      <td><span class="order-id">${o.id||""}</span></td>
      <td>${o.customer_name||"Unknown"}</td>
      <td>${o.service_type||"Service"}</td>
      <td>${w(o.total_price||0)}</td>
      <td><span class="status-pill" data-status="${i}">${o.status||"Pending"}</span></td>
    `,e.appendChild(a)})}}const vt=[{bg:"#EDE9FE",color:"#5B21B6"},{bg:"#CCFBF1",color:"#0F766E"},{bg:"#DBEAFE",color:"#1D4ED8"},{bg:"#FFE4E6",color:"#BE123C"},{bg:"#FEF3C7",color:"#92400E"},{bg:"#D1FAE5",color:"#065F46"}],qt=["gold","silver","bronze","plain"],Vt=["1","2","3","4"];function st(t,e){const o=typeof e=="string"?s(e):e;if(o){if(o.innerHTML="",!t.length){o.innerHTML='<div style="font-size:13px;color:var(--color-text-secondary)">No data yet.</div>';return}t.forEach((a,i)=>{const r=(a.name||"C").split(" ").map(g=>g[0]).join("").toUpperCase().slice(0,2),d=vt[i%vt.length],l=qt[Math.min(i,3)],p=Vt[Math.min(i,3)],u=document.createElement("div");u.className="top-customer-row",u.innerHTML=`
      <span class="medal-dot ${l}">${p}</span>
      <span class="customer-avatar" style="background:${d.bg};color:${d.color}">${r}</span>
      <div class="top-customer-info">
        <div class="top-customer-name">${a.name||"Customer"}</div>
        <div class="top-customer-meta">${a.orders||0} orders</div>
      </div>
      <div class="top-customer-spend">${a.spend||""}</div>
    `,o.appendChild(u)})}}function G(t){j("#booking-status-chips [data-status]").forEach(e=>{e.classList.toggle("active",e.dataset.status===t)})}async function Wt(){const t=await f("/admin/booking-summaries");if(!t.ok)return;const e=t.data?.data||{},o=e.by_status||{},a=e.total??0;j("[data-status-count]").forEach(i=>{const r=i.dataset.statusCount,d=r==="all"?a:o[r]??0;c(i,d)})}function $t(t,e){const o=Mt(e);return e==="ready"||e==="completed"?(n.bookings.steps[t]=o,o):n.bookings.steps[t]!==void 0?n.bookings.steps[t]:o!==null?(n.bookings.steps[t]=o,o):null}function Yt(t,e){return e===null?"":["Washing","Drying","Ready","Done"].map((a,i)=>`<button class="step-chip ${i===e?"active":""}" data-booking-step="${i}" data-order-id="${t}" type="button">${a}</button>`).join("")}function Jt(t,e){const o=[];return e==="pending"&&(o.push(`<button class="button-outline btn-sm btn-success" data-booking-action="accept" data-order-id="${t}" type="button">Accept</button>`),o.push(`<button class="button-outline btn-sm btn-danger" data-booking-action="decline" data-order-id="${t}" type="button">Decline</button>`)),(e==="ongoing"||e==="ready")&&o.push(`<button class="button-outline btn-sm btn-success" data-booking-action="complete" data-order-id="${t}" type="button">Complete</button>`),o.join("")}function _t(t){const e=String(t),o=n.bookings.byId[e];if(!o)return;n.bookings.activeOrderId=e;const a=s("#booking-modal"),i=s("#booking-modal-overlay"),r=s("#booking-modal-body"),d=s("#booking-modal-title"),l=s("#booking-modal-subtitle"),p=ot(o),u=Z(o.status)||"pending";d&&(d.textContent="Booking details"),l&&(l.textContent=`${p} · ${u}`),r&&(r.innerHTML=Tt(o)),i&&i.classList.add("show"),a&&(a.classList.add("show"),a.classList.remove("hidden"))}function xt(){n.bookings.activeOrderId=null,s("#booking-modal-overlay")?.classList.remove("show");const t=s("#booking-modal");t&&(t.classList.remove("show"),t.classList.add("hidden"))}function bt(t){const e=t.dataset.orderId,o=t.dataset.bookingAction;o==="accept"?(n.bookings.steps[e]=0,W(e,"ongoing")):o==="decline"?W(e,"cancelled"):o==="complete"&&(n.bookings.steps[e]=3,W(e,"completed"))}function ft(t){const e=t.dataset.orderId,o=Number(t.dataset.bookingStep);Number.isNaN(o)||(n.bookings.steps[e]=o,W(e,At(o)))}async function U(){const t=Wt(),e=s("#bookings-filter");e&&(e.value=n.bookings.status);const o=new URLSearchParams({page:n.bookings.page.toString(),per_page:n.bookings.perPage.toString()});n.bookings.status&&n.bookings.status!=="all"&&o.set("status",n.bookings.status);const a=await f(`/admin/orders?${o.toString()}`),i=s("#bookings-table-body");if(!i)return;if(i.innerHTML="",!a.ok){i.innerHTML='<tr><td colspan="8">Unable to load bookings.</td></tr>';return}const r=a.data?.data||[],d=a.data?.pagination||{};if(n.bookings.byId={},!r.length){i.innerHTML='<tr><td colspan="8">No bookings found.</td></tr>',await t,G(n.bookings.status);return}r.forEach(v=>{const _=v.order_id||v.id,R=String(_);n.bookings.byId[R]=v;const C=Z(v.status);$t(_,C);const S=document.createElement("tr"),P=(v.customer_name||"Customer").split(" ").map(A=>A[0]).join("").substring(0,2).toUpperCase(),L=$(v.created_at),x=ot(v),T=[{bg:"#EEEDFE",color:"#3C3489"},{bg:"#E1F5EE",color:"#085041"},{bg:"#E6F1FB",color:"#0C447C"}],M=T[(v.customer_id||0)%T.length];S.innerHTML=`
      <td><span class="order-id">${x}</span></td>
      <td>
        <div class="order-customer-cell">
          <span class="order-customer-avatar" style="background:${M.bg};color:${M.color}">${P}</span>
          <span class="order-customer-name">${v.customer_name||"Unknown"}</span>
        </div>
      </td>
      <td>${v.service_type||"Service"}</td>
      <td>${v.weight_kg||0} kg</td>
      <td>${w(v.total_price||0)}</td>
      <td>
        <span class="status-pill" data-status="${C}">
          <span class="status-dot"></span>
          ${C}
        </span>
      </td>
      <td><span class="order-created-date">${L}</span></td>
      <td>
        <div style="display:flex; gap:6px;">
          <button class="btn-details" data-booking-toggle="${_}" type="button">
            Details
          </button>
          <button class="button-outline" data-cod-receipt-id="${_}" type="button">
            Receipt
          </button>
        </div>
      </td>
    `,i.appendChild(S)});const l=d.total||r.length;c("#bookings-footer-info",`Showing ${r.length} of ${l} orders — Page ${d.current_page||1} of ${d.last_page||1}`);const p=s("#bookings-prev"),u=s("#bookings-next"),g=s("#bookings-current-page");p&&(p.disabled=(d.current_page||1)<=1),u&&(u.disabled=(d.current_page||1)>=(d.last_page||1)),g&&(g.textContent=d.current_page||1),await t,G(n.bookings.status)}async function W(t,e){const o=String(t),a=await f(`/admin/orders/${t}/status`,{method:"PATCH",body:{status:e}});if(!a.ok){h("Unable to update status.");return}h("Order status updated.");const i=a.data?.data;await U(),i&&(n.bookings.byId[o]=i),n.bookings.activeOrderId===o&&_t(t)}async function Y(){const t=new URLSearchParams({page:n.customers.page.toString(),per_page:n.customers.perPage.toString()});n.customers.search&&t.set("search",n.customers.search);const e=await f(`/admin/customers?${t.toString()}`),o=s("#customers-table-body");if(!o)return;if(o.innerHTML="",!e.ok){o.innerHTML='<tr><td colspan="6">Unable to load customers.</td></tr>';return}const a=e.data?.data||[],i=e.data?.pagination||{};a.length||(o.innerHTML='<tr><td colspan="6">No customers found.</td></tr>'),a.forEach(l=>{const p=document.createElement("tr");p.innerHTML=`
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
    `,o.appendChild(p)}),c("#customers-page-info",`Page ${i.current_page||1} of ${i.last_page||1}`);const r=s("#customers-prev"),d=s("#customers-next");r&&(r.disabled=(i.current_page||1)<=1),d&&(d.disabled=(i.current_page||1)>=(i.last_page||1))}async function Kt(t){n.currentCustomerId=t,s("#customer-drawer")?.classList.add("open"),s("#drawer-overlay")?.classList.add("show"),c("#customer-drawer-title","Loading...");const e=await f(`/admin/customers/${t}`);if(!e.ok){h("Unable to load customer.");return}const o=e.data?.data||{};c("#customer-drawer-title",o.name||"Customer"),s("#customer-name").value=o.name||"",s("#customer-email").value=o.email||"",s("#customer-phone").value=o.phone||"",s("#customer-address").value=o.address||"",s("#customer-city").value=o.city||"",s("#customer-zip").value=o.zip_code||"",s("#customer-country").value=o.country||"",s("#customer-notifications").checked=o.notifications_enabled!==!1,c("#customer-loyalty",o.loyalty_points||0),c("#customer-orders-count",o.orders_count||0),c("#customer-total-spent",w(o.total_spent||0)),c("#customer-dob",I($(o.date_of_birth))),c("#customer-gender",I(o.gender)),c("#customer-language",I(o.preferred_language)),c("#customer-email-verified",ut(!!o.email_verified_at)),c("#customer-profile-completed",ut(!!o.profile_completed_at)),c("#customer-member-since",I($(o.created_at))),c("#customer-last-login",I($(o.last_login_at))),c("#customer-bio",I(o.bio)),n.customerOrders.page=1,n.customerOrders.lastPage=1,await Et(!0)}function yt(){s("#customer-drawer")?.classList.remove("open"),s("#drawer-overlay")?.classList.remove("show"),n.currentCustomerId=null}async function Gt(){if(!n.currentCustomerId)return;const t={name:s("#customer-name").value.trim(),phone:s("#customer-phone").value.trim()||null,address:s("#customer-address").value.trim()||null,city:s("#customer-city").value.trim()||null,zip_code:s("#customer-zip").value.trim()||null,country:s("#customer-country").value.trim()||null,notifications_enabled:s("#customer-notifications").checked};if(!(await f(`/admin/customers/${n.currentCustomerId}`,{method:"PUT",body:t})).ok){h("Unable to update customer.");return}h("Customer updated."),await Y()}async function Et(t=!1){if(!n.currentCustomerId)return;t&&(n.customerOrders.page=1);const e=new URLSearchParams({page:n.customerOrders.page.toString(),per_page:n.customerOrders.perPage.toString()}),o=await f(`/admin/customers/${n.currentCustomerId}/orders?${e.toString()}`),a=s("#customer-orders-body");if(!a)return;if(!o.ok){t&&(a.innerHTML='<tr><td colspan="5">Unable to load orders.</td></tr>');return}const i=o.data?.data||[],r=o.data?.pagination||{};t&&(a.innerHTML=""),!i.length&&t&&(a.innerHTML='<tr><td colspan="5">No orders yet.</td></tr>'),i.forEach(u=>{const g=document.createElement("tr");g.innerHTML=`
      <td>${u.id||""}</td>
      <td>${u.service_type||""}</td>
      <td>${u.weight_kg||0} kg</td>
      <td>${w(u.total_price||0)}</td>
      <td>${u.status||""}</td>
    `,a.appendChild(g)}),n.customerOrders.lastPage=r.last_page||1;const d=r.current_page||n.customerOrders.page;c("#customer-orders-page-info",`Page ${d} of ${n.customerOrders.lastPage}`);const l=Number.isFinite(r.total)?r.total:i.length;c("#customer-orders-title-count",`(${l})`);const p=s("#customer-orders-load");if(p){const u=d>=n.customerOrders.lastPage;p.disabled=u,p.classList.toggle("hidden",u||l===0)}}async function Zt(){const t=await f("/admin/analytics");if(!t.ok){h("Unable to load analytics.");return}const e=t.data||{},o=Number(e.monthly_revenue||0),a=Number(e.total_orders_this_month||0),i=Number(e.completed_orders_this_month||0),r=Number(e.cancelled_orders_this_month||0),d=Number(e.new_customers_this_month||0),l=Number(e.total_customers||0),p=Number(e.completion_rate||0),u=e.top_service||null,g=Array.isArray(e.top_customers)?e.top_customers:[],v=g[0]||null;c("#analytics-month",e.month_label||""),c("#analytics-monthly-revenue",w(o)),c("#analytics-monthly-card",w(o)),c("#analytics-completion-rate",`${p}%`),c("#analytics-monthly-orders",a),c("#analytics-new-customers",d),c("#analytics-total-customers",`${l} total customers`),c("#analytics-completed-orders",i),c("#analytics-cancelled-orders",`${r} cancelled`),c("#analytics-top-service",u?.name||"No service data yet"),c("#analytics-top-service-meta",u?`${u.orders||0} orders`:"No completed order mix yet"),c("#analytics-top-customer",v?.name||"No customer data yet"),c("#analytics-top-customer-meta",v?`${v.orders||0} orders · ${v.spend_label||w(v.spend||0)}`:"No customer orders yet"),c("#analytics-order-health",`${p}% completion`);const _=e.weekly_revenue||[],R=Math.max(1,..._.map(b=>Number(b||0))),C=["Mon","Tue","Wed","Thu","Fri","Sat","Sun"],S=s("#weekly-bars");S.innerHTML="",_.forEach((b,D)=>{const k=Math.round(Number(b||0)/R*100),E=document.createElement("div");E.className="weekly-bar",E.innerHTML=`
      <div class="weekly-bar-value">${w(Number(b||0))}</div>
      <div class="weekly-bar-track" title="${w(Number(b||0))}">
        <div class="weekly-bar-fill" style="height:${k}%;"></div>
      </div>
      <div class="weekly-bar-label">${C[D]||""}</div>
    `,S.appendChild(E)});const P=e.service_breakdown||[],L=s("#service-breakdown-body"),x=s("#service-breakdown-donut"),T=s("#service-breakdown-total");L&&(L.innerHTML="");const M=["#3B82F6","#34D399","#F59E0B","#EC4899","#A78BFA","#22D3EE"];let A=0,O=0;const B=[];if(!P.length)L&&(L.innerHTML='<div class="analytics-empty">No service data yet.</div>'),x&&(x.style.background="conic-gradient(rgba(148, 163, 184, 0.2) 0% 100%)"),T&&c("#service-breakdown-total","0%");else if(P.forEach((b,D)=>{const k=Math.max(0,Math.min(100,Number(b.pct||0))),E=M[D%M.length];if(k>0&&B.push(`${E} ${A}% ${A+k}%`),A+=k,O+=k,L){const F=document.createElement("div");F.className="breakdown-legend-row",F.innerHTML=`
          <span class="breakdown-legend-swatch" style="background:${E};"></span>
          <div class="breakdown-legend-copy">
            <div class="breakdown-legend-name">${q(b.name||"Service")}</div>
            <div class="breakdown-legend-meta">${k}% &middot; ${b.count||0} orders</div>
          </div>
        `,L.appendChild(F)}}),x){const b=Math.min(100,Math.round(O));O<100&&B.push(`rgba(148, 163, 184, 0.2) ${O}% 100%`),x.style.background=`conic-gradient(${B.join(", ")})`,T&&c("#service-breakdown-total",`${b}%`)}const H=s("#analytics-top-customers-list");H&&(H.innerHTML="",g.length?g.forEach((b,D)=>{const k=document.createElement("div");k.className="analytics-customer-row",k.innerHTML=`
          <span class="analytics-rank">${D+1}</span>
          <div class="analytics-customer-copy">
            <strong>${q(b.name||"Customer")}</strong>
            <span>${b.orders||0} orders</span>
          </div>
          <div class="analytics-customer-spend">${b.spend_label||w(b.spend||0)}</div>
        `,H.appendChild(k)}):H.innerHTML='<div class="analytics-empty">No customer spend data yet.</div>')}async function nt(){const[t,e]=await Promise.all([f("/admin/services"),f("/admin/top-customers")]),o=s("#services-table-body");if(!o)return;if(o.innerHTML="",!t.ok){o.innerHTML='<tr><td colspan="6">Unable to load services.</td></tr>',st(e.ok?e.data?.data||[]:[],"#services-top-customers-body");return}const a=t.data?.data||[];a.length||(o.innerHTML='<tr><td colspan="6">No services found.</td></tr>'),a.forEach(i=>{const r=document.createElement("tr");r.innerHTML=`
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
    `,o.appendChild(r)}),st(e.ok?e.data?.data||[]:[],"#services-top-customers-body")}async function Qt(){const t={name:s("#service-name").value.trim(),description:s("#service-description").value.trim()||null,price_per_kg:Number(s("#service-price").value||0),category:s("#service-category").value.trim()||null,image_url:s("#service-image").value.trim()||null,is_active:s("#service-active").checked},e=n.services.editingId;if(!(await f(`/admin/services${e?`/${e}`:""}`,{method:e?"PUT":"POST",body:t})).ok){h("Unable to save service.");return}h(e?"Service updated.":"Service created."),Ct(),await nt()}function Ct(){n.services.editingId=null,c("#service-form-title","Create service"),s("#service-name").value="",s("#service-description").value="",s("#service-price").value="",s("#service-category").value="",s("#service-image").value="",s("#service-active").checked=!0}async function Xt(t){const e=await f("/admin/services");if(!e.ok)return;const a=(e.data?.data||[]).find(i=>i.id===Number(t));a&&(n.services.editingId=a.id,c("#service-form-title","Update service"),s("#service-name").value=a.name||"",s("#service-description").value=a.description||"",s("#service-price").value=a.price_per_kg||"",s("#service-category").value=a.category||"",s("#service-image").value=a.image_url||"",s("#service-active").checked=a.is_active!==!1)}async function te(t){if(!window.confirm("Delete this service?"))return;if(!(await f(`/admin/services/${t}`,{method:"DELETE"})).ok){h("Unable to delete service.");return}h("Service deleted."),await nt()}function ht(t,e,o){t.type=o?"text":"password",e.setAttribute("aria-pressed",o?"true":"false"),e.setAttribute("aria-label",o?"Hide password":"Show password"),e.innerHTML=o?'<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>':'<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>'}function ee(){const t=s("#login-form");t&&t.addEventListener("submit",It);const e=s("#toggle-password"),o=s("#login-password");e&&o&&(ht(o,e,!1),e.addEventListener("click",()=>{const m=o.type==="password";ht(o,e,m)}));const a=s("#logout-button");a&&a.addEventListener("click",Rt);const i=s("#logout-modal-cancel");i&&i.addEventListener("click",gt);const r=s("#logout-modal-confirm");r&&r.addEventListener("click",Ft);const d=s("#logout-modal-overlay");d&&d.addEventListener("click",gt),j("[data-view]").forEach(m=>{m.addEventListener("click",()=>{et(m.dataset.view),pt()})});const l=s("#bookings-filter");l&&l.addEventListener("change",m=>{n.bookings.status=m.target.value,n.bookings.page=1,G(n.bookings.status),U()});const p=s("#booking-status-chips");p&&p.addEventListener("click",m=>{const y=m.target.closest("[data-status]");y&&(n.bookings.status=y.dataset.status,n.bookings.page=1,G(n.bookings.status),l&&(l.value=n.bookings.status),U())});const u=s("#bookings-prev");u&&u.addEventListener("click",()=>{n.bookings.page=Math.max(1,n.bookings.page-1),U()});const g=s("#bookings-next");g&&g.addEventListener("click",()=>{n.bookings.page+=1,U()});const v=s("#bookings-table-body");v&&(v.addEventListener("change",m=>{const y=m.target.closest("select[data-order-id]");y&&W(y.dataset.orderId,y.value)}),v.addEventListener("click",m=>{const y=m.target.closest("[data-cod-receipt-id]");if(y){const Q=y.dataset.codReceiptId,lt=n.bookings.byId[String(Q)];lt?se(lt):h("Receipt data unavailable. Please refresh.");return}const N=m.target.closest("[data-booking-toggle]");if(N){const Q=N.dataset.bookingToggle;_t(Q);return}const ct=m.target.closest("[data-booking-action]");if(ct){bt(ct);return}const dt=m.target.closest("[data-booking-step]");dt&&ft(dt)}));const _=s("#booking-modal-close");_&&_.addEventListener("click",xt);const R=s("#booking-modal");R&&R.addEventListener("click",m=>{const y=m.target.closest("[data-booking-action]");if(y){bt(y);return}const N=m.target.closest("[data-booking-step]");N&&ft(N)});const C=s("#customers-search-button");C&&C.addEventListener("click",()=>{n.customers.search=s("#customers-search-input").value.trim(),n.customers.page=1,Y()});const S=s("#customers-prev");S&&S.addEventListener("click",()=>{n.customers.page=Math.max(1,n.customers.page-1),Y()});const P=s("#customers-next");P&&P.addEventListener("click",()=>{n.customers.page+=1,Y()});const L=s("#customers-table-body");L&&L.addEventListener("click",m=>{const y=m.target.closest("[data-customer-id]");y&&Kt(y.dataset.customerId)});const x=s("#customer-drawer-close");x&&x.addEventListener("click",yt);const T=s("#drawer-overlay");T&&T.addEventListener("click",yt);const M=s("#customer-save");M&&M.addEventListener("click",Gt);const A=s("#customer-orders-load");A&&A.addEventListener("click",()=>{n.customerOrders.page>=n.customerOrders.lastPage||(n.customerOrders.page+=1,Et())});const O=s("#service-save");O&&O.addEventListener("click",Qt);const B=s("#service-clear");B&&B.addEventListener("click",Ct);const H=s("#services-table-body");H&&H.addEventListener("click",m=>{const y=m.target.closest("[data-edit-service]");if(y){Xt(y.dataset.editService);return}const N=m.target.closest("[data-delete-service]");N&&te(N.dataset.deleteService)});const b=s("#recent-orders-view-all");b&&b.addEventListener("click",()=>et("bookings"));const D=s("#sidebar-toggle");D&&D.addEventListener("click",Ot);const k=s("#sidebar-overlay");k&&k.addEventListener("click",pt);const E=s("#cod-receipt-close");E&&E.addEventListener("click",X);const F=s("#cod-receipt-cancel");F&&F.addEventListener("click",X);const it=s("#cod-receipt-print");it&&it.addEventListener("click",oe);const rt=s("#cod-receipt-overlay");rt&&rt.addEventListener("click",X)}window.addEventListener("DOMContentLoaded",()=>{ee(),Ht()});function se(t){const e=s("#cod-receipt-modal"),o=s("#cod-receipt-overlay"),a=s("#cod-receipt-body");if(!e||!o||!a)return;const i=ot(t),r=kt(t.delivery_type),d=$(t.pickup_date),l=$(t.delivery_date),p=$(t.created_at),u=w(t.total_price||0);a.innerHTML=`
    <div id="cod-receipt-print-area" style="font-family:'Work Sans',Arial,sans-serif; color:#08213D;">

      <div style="text-align:center; padding:16px 0 12px;">
        <div style="font-size:11px; font-weight:700; letter-spacing:0.16em; text-transform:uppercase; color:#58708D; margin-bottom:4px;">LaundryHub</div>
        <div style="font-size:22px; font-weight:700; margin-bottom:2px;">COD Receipt</div>
        <div style="font-size:12px; color:#58708D;">${i}</div>
      </div>

      <div style="border-top:1px solid rgba(21,101,192,0.14); border-bottom:1px solid rgba(21,101,192,0.14); padding:14px 0; margin:8px 0;">
        <table style="width:100%; border-collapse:collapse; font-size:13px;">
          <tr>
            <td style="padding:6px 0; color:#58708D; width:45%;">Customer</td>
            <td style="padding:6px 0; font-weight:600;">${q(t.customer_name||"N/A")}</td>
          </tr>
          <tr>
            <td style="padding:6px 0; color:#58708D;">Address</td>
            <td style="padding:6px 0; font-weight:500;">${q(t.pickup_address||"N/A")}</td>
          </tr>
          <tr>
            <td style="padding:6px 0; color:#58708D;">Service</td>
            <td style="padding:6px 0; font-weight:500;">${q(t.service_type||"---")}</td>
          </tr>
          <tr>
            <td style="padding:6px 0; color:#58708D;">Weight</td>
            <td style="padding:6px 0;">${t.weight_kg||0} kg</td>
          </tr>
          <tr>
            <td style="padding:6px 0; color:#58708D;">Fulfillment</td>
            <td style="padding:6px 0;">${r}</td>
          </tr>
          <tr>
            <td style="padding:6px 0; color:#58708D;">Pickup Date</td>
            <td style="padding:6px 0;">${d}</td>
          </tr>
          <tr>
            <td style="padding:6px 0; color:#58708D;">Delivery Date</td>
            <td style="padding:6px 0;">${l}</td>
          </tr>
          <tr>
            <td style="padding:6px 0; color:#58708D;">Order Date</td>
            <td style="padding:6px 0;">${p}</td>
          </tr>
        </table>
      </div>

      <div style="display:flex; align-items:center; justify-content:space-between; padding:14px 0 6px;">
        <span style="font-size:14px; font-weight:600;">Total Amount</span>
        <span style="font-size:20px; font-weight:700; color:#1565C0;">${u}</span>
      </div>

      <div style="background:#E1F5EE; border-radius:8px; padding:10px 14px; margin-top:8px; display:flex; align-items:center; gap:8px;">
        <span style="font-size:16px;">✓</span>
        <div>
          <div style="font-size:12px; font-weight:700; color:#085041;">Cash on Delivery (COD)</div>
          <div style="font-size:11px; color:#085041; margin-top:1px;">Payment collected upon delivery/pickup.</div>
        </div>
      </div>

    </div>
  `,e.classList.remove("hidden"),e.classList.add("show"),o.classList.add("show")}function X(){const t=s("#cod-receipt-modal"),e=s("#cod-receipt-overlay");t&&(t.classList.remove("show"),t.classList.add("hidden")),e&&e.classList.remove("show")}function oe(){const t=s("#cod-receipt-print-area");if(!t)return;const e=window.open("","_blank","width=600,height=700");if(!e){h("Please allow pop-ups to print.");return}e.document.write(`
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <title>COD Receipt</title>
        <style>
          body { font-family: Arial, sans-serif; padding: 32px; color: #08213D; max-width: 480px; margin: 0 auto; }
          table { width: 100%; border-collapse: collapse; }
          td { padding: 7px 0; font-size: 13px; vertical-align: top; }
          hr { border: none; border-top: 1px solid #ddd; margin: 14px 0; }
        </style>
      </head>
      <body>
        ${t.innerHTML}
      </body>
    </html>
  `),e.document.close(),e.focus(),e.print()}
