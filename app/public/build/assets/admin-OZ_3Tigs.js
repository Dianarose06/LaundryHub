import"./app-UyRVujZY.js";const n={token:null,user:null,isLoginSubmitting:!1,isLogoutSubmitting:!1,view:"dashboard",bookings:{page:1,perPage:20,status:"all",steps:{},byId:{},activeOrderId:null},customers:{page:1,perPage:20,search:""},services:{editingId:null},customerOrders:{page:1,perPage:10,lastPage:1},currentCustomerId:null},s=(t,e=document)=>e.querySelector(t),W=(t,e=document)=>Array.from(e.querySelectorAll(t)),j=`${window.LAUNDRYHUB_API_BASE_URL||"/api"}`.trim().replace(/\/$/,""),Tt=(()=>{if(!j)return"/api";if(j.startsWith("/"))return j;if(!j.startsWith("http"))return`/${j.replace(/^\/+/,"")}`;try{return new URL(j,window.location.origin).pathname.replace(/\/$/,"")||"/api"}catch{return"/api"}})();function l(t,e){const o=typeof t=="string"?s(t):t;o&&(o.textContent=e)}function V(t){t&&t.classList.remove("hidden")}function X(t){t&&t.classList.add("hidden")}function w(t){const e=s("#toast");e&&(e.textContent=t,e.classList.add("show"),e.setAttribute("aria-hidden","false"),setTimeout(()=>{e.classList.remove("show"),e.setAttribute("aria-hidden","true")},3e3))}function L(t){return`PHP ${Number(t||0).toLocaleString("en-PH",{maximumFractionDigits:0})}`}function _(t){if(!t)return"---";const e=new Date(t);return Number.isNaN(e.getTime())?t:e.toLocaleDateString("en-PH",{month:"short",day:"numeric",year:"numeric"})}function I(t,e="---"){return t==null||t===""?e:t}function R(t){return`${t??""}`.replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;").replaceAll('"',"&quot;").replaceAll("'","&#039;")}function mt(t){return t?"Yes":"No"}function st(t){return`${t||""}`.trim().toLowerCase()}function A(t){return(t||"").toString().toLowerCase()}function it(t){return(A(t)||"pickup")==="delivery"?"Delivery":"Pickup"}function K(t){const e=t?.id??t?.order_id??"",o=String(e).replace(new RegExp("^#?LH-+"),"");return o?`#LH-${o.padStart(3,"0")}`:String(e||"---")}function At(t){const e=t.order_id||t.id,o=A(t.status),a=_t(e,o),i=_(t.pickup_date),d=_(t.delivery_date||t.pickup_date),u=it(t.delivery_type),g=I(t.pickup_address),c=_(t.updated_at),r=["ongoing","ready","completed"].includes(o)?Jt(e,a):"",p=Kt(e,o);return`
    <div class="details-grid">
      <div>
        <div class="details-label">Pickup date</div>
        <div class="details-value">${i}</div>
      </div>
      <div>
        <div class="details-label">Delivery date</div>
        <div class="details-value">${d}</div>
      </div>
      <div>
        <div class="details-label">Delivery type</div>
        <div class="details-value">${u}</div>
      </div>
      <div>
        <div class="details-label">Pickup address</div>
        <div class="details-value">${g}</div>
      </div>
      <div>
        <div class="details-label">Created</div>
        <div class="details-value">${_(t.created_at)}</div>
      </div>
      <div>
        <div class="details-label">Updated</div>
        <div class="details-value">${c}</div>
      </div>
    </div>
    <div class="details-actions">
      ${r?`<div class="step-chips">${r}</div>`:"<div></div>"}
      <div class="action-buttons">${p||'<span class="text-xs text-muted">No actions</span>'}</div>
    </div>
  `}function Mt(t){return t==="ready"?2:t==="completed"?3:t==="ongoing"?0:null}function Ft(t){return t===2?"ready":t===3?"completed":"ongoing"}function at(t){n.view=t,W(".view-section").forEach(e=>{e.classList.toggle("hidden",e.dataset.view!==t)}),W("[data-view]").forEach(e=>{e.classList.toggle("active",e.dataset.view===t)}),jt(t).catch(e=>{console.error("Failed to load view",e)})}function $t(t,e){localStorage.setItem("lh_admin_token",t),localStorage.setItem("lh_admin_user",JSON.stringify(e)),n.token=t,n.user=e}function G(){localStorage.removeItem("lh_admin_token"),localStorage.removeItem("lh_admin_user"),n.token=null,n.user=null}function Lt(){return window.location.pathname==="/admin"}function Pt(){return window.location.pathname.startsWith("/admin/dashboard")}function Q(){if(Ct(),!Lt()){window.location.assign("/admin");return}V(s(".bg-aurora")),V(s("#login-view")),X(s("#app-view"))}function Nt(){if(!Pt()){window.location.assign("/admin/dashboard");return}if(X(s(".bg-aurora")),X(s("#login-view")),V(s("#app-view")),Ot(),n.user){const t=n.user.name?.trim()||"LaundryHub Admin",e="Admin",o=e.charAt(0).toUpperCase()||"A",a=n.user.email||"admin@laundryhub.com";l("#user-name",t),l("#user-email",n.user.email||""),l("#header-admin-name",e),l("#header-admin-avatar",o),l("#sidebar-admin-name",e),l("#sidebar-admin-email",a),l("#sidebar-admin-avatar",o)}}function Ot(){W('.bg-aurora, [class*="watermark"], [id*="watermark"]').forEach(e=>{e.style.display="none"})}function bt(){s(".sidebar")?.classList.remove("open"),s("#sidebar-overlay")?.classList.remove("show"),s("#sidebar-toggle")?.setAttribute("aria-expanded","false")}function zt(){const t=s(".sidebar"),e=s("#sidebar-overlay"),o=s("#sidebar-toggle");if(!t||!e||!o)return;const a=t.classList.toggle("open");e.classList.toggle("show",a),o.setAttribute("aria-expanded",a?"true":"false")}function ft(t){const e=s("#login-submit"),o=s("#login-submit .btn-spinner"),a=s("#login-submit .btn-label"),i=s("#login-email"),d=s("#login-password");e&&(e.disabled=t,e.classList.toggle("is-loading",t),e.setAttribute("aria-busy",t?"true":"false")),o&&o.classList.toggle("hidden",!t),a&&(a.textContent=t?"Signing in...":"Sign in"),i&&(i.disabled=t),d&&(d.disabled=t)}function rt(t){const e=s("#logout-modal-confirm"),o=s("#logout-modal-confirm .btn-spinner"),a=s("#logout-modal-confirm .btn-label"),i=s("#logout-modal-cancel");e&&(e.disabled=t,e.classList.toggle("is-loading",t),e.setAttribute("aria-busy",t?"true":"false")),o&&o.classList.toggle("hidden",!t),a&&(a.textContent=t?"Logging out...":"Yes"),i&&(i.disabled=t)}const et=new Map;async function v(t,e={}){const o=new AbortController,a=Number.isFinite(e.timeoutMs)?e.timeoutMs:8e3,i=a>0?setTimeout(()=>o.abort(),a):null,d=e.suppressToast===!0,u=e.method||"GET";u!=="GET"&&et.clear();const g=t+(e.body?JSON.stringify(e.body):""),c=u==="GET"&&e.cache!==!1;if(c){const p=et.get(g);if(p&&Date.now()-p.timestamp<3e4)return p.res}const r={method:u,headers:{Accept:"application/json",...e.headers},signal:o.signal};!e.skipAuth&&n.token&&(r.headers.Authorization=`Bearer ${n.token}`),e.body&&(r.headers["Content-Type"]="application/json",r.body=JSON.stringify(e.body));try{const p=await fetch(`${Tt}${t}`,r);i&&clearTimeout(i);let m=null;try{m=await p.json()}catch{m=null}(p.status===401||p.status===403)&&(G(),Q(),w("Session expired. Please sign in again."));const h={ok:p.ok,status:p.status,data:m};return c&&p.ok&&et.set(g,{res:h,timestamp:Date.now()}),h}catch(p){return i&&clearTimeout(i),p?.name==="AbortError"?(d||w("Request timed out. The server may still be starting up."),{ok:!1,status:408,data:{message:"Request timed out."}}):(d||w("Network error. Please try again."),{ok:!1,status:0,data:null})}}async function Ht(){const t=Lt(),e=localStorage.getItem("lh_admin_token"),o=localStorage.getItem("lh_admin_user");if(!e||!o){G(),Q();return}let a=null;try{a=JSON.parse(o)}catch{G(),Q();return}if(!a||st(a.role)!=="admin"){G(),Q();return}if(t){window.location.assign("/admin/dashboard");return}n.token=e,n.user=a,Nt(),at("dashboard"),v("/user").then(i=>{i.ok&&st(i.data?.role)==="admin"&&$t(e,i.data)}).catch(()=>{})}async function It(t){if(t.preventDefault(),n.isLoginSubmitting)return;const e=s("#login-email")?.value.trim()||"",o=s("#login-password")?.value||"",a=s("#login-error");X(a),n.isLoginSubmitting=!0,ft(!0);let i=!1,d;try{if(d=await v("/login",{method:"POST",body:{email:e,password:o},skipAuth:!0,timeoutMs:45e3}),!d.ok){const p=d.data?.message||`Login failed (Status: ${d.status||"Unknown"})`;l(a,p),V(a);return}const u=d.data?.user||d.data?.data?.user||null,g=`${d.data?.token||d.data?.access_token||d.data?.data?.token||d.data?.data?.access_token||""}`.trim(),c=st(u?.role||d.data?.role||d.data?.data?.role);if(!g){l(a,"Login failed. Missing access token."),V(a);return}if(c!=="admin"){l(a,"This account does not have admin access."),V(a);return}$t(g,u||{role:"admin",email:e}),i=!0,window.location.assign("/admin/dashboard")}finally{n.isLoginSubmitting=!1,i||ft(!1)}}async function Rt(){Bt()}function Bt(){n.isLogoutSubmitting||(rt(!1),s("#logout-modal-overlay")?.classList.add("show"),s("#logout-modal")?.classList.remove("hidden"),s("#logout-modal")?.classList.add("show"))}function vt(){n.isLogoutSubmitting||(rt(!1),s("#logout-modal-overlay")?.classList.remove("show"),s("#logout-modal")?.classList.remove("show"),s("#logout-modal")?.classList.add("hidden"))}async function Ut(){if(!n.isLogoutSubmitting){n.isLogoutSubmitting=!0,rt(!0);try{n.token&&await v("/logout",{method:"POST"})}catch{}finally{G(),window.location.assign("/admin")}}}async function jt(t){t==="dashboard"?await qt():t==="bookings"?await q():t==="customers"?await J():t==="analytics"?await Zt():t==="services"&&await dt()}async function qt(){l("#stat-total-bookings","--"),l("#stat-pending","--"),l("#stat-revenue","--"),l("#stat-customers","--");const t=await v("/admin/dashboard-batch",{timeoutMs:2e4,suppressToast:!0});let e={},o=[],a=[];if(t.ok)e=t.data?.stats??{},o=t.data?.recent_orders??[],a=t.data?.top_customers??[];else{const[h,y,b]=await Promise.all([v("/admin/stats",{timeoutMs:2e4,suppressToast:!0}),v("/admin/orders/recent",{timeoutMs:2e4,suppressToast:!0}),v("/admin/top-customers",{timeoutMs:2e4,suppressToast:!0})]);e=h.ok?h.data||{}:{},o=y.ok?y.data?.data||[]:[],a=b.ok?b.data?.data||[]:[]}const i=e.total_bookings??0,d=e.pending_count??0,u=e.revenue_today??0,g=e.customer_count??0;l("#stat-total-bookings",i),l("#stat-pending",d),l("#stat-revenue",L(u)),l("#stat-customers",g);const c=s("#stat-badge-total");c&&(c.className="stat-badge green",c.textContent="All time");const r=s("#stat-badge-pending");r&&(r.className=d>0?"stat-badge amber":"stat-badge green",r.textContent=d>0?"Needs action":"All clear");const p=s("#stat-badge-revenue");p&&(p.className=u>0?"stat-badge green":"stat-badge red",p.textContent=u>0?"Live sales":"No revenue yet");const m=s("#stat-badge-customers");m&&(m.className="stat-badge green",m.textContent="Growing"),Vt(o),nt(a,"#top-customers-body"),v("/admin/customers?page=1&per_page=20",{timeoutMs:2e4,suppressToast:!0}).catch(()=>{}),v("/admin/analytics",{timeoutMs:2e4,suppressToast:!0}).catch(()=>{})}function Vt(t){const e=s("#recent-orders-body");if(e){if(e.innerHTML="",!t.length){e.innerHTML='<tr><td colspan="5">No recent orders.</td></tr>';return}t.forEach(o=>{const a=document.createElement("tr"),i=(o.status||"").toString().toLowerCase();a.innerHTML=`
      <td><span class="order-id">${o.id||""}</span></td>
      <td>${o.customer_name||"Unknown"}</td>
      <td>${o.service_type||"Service"}</td>
      <td>${L(o.total_price||0)}</td>
      <td><span class="status-pill" data-status="${i}">${o.status||"Pending"}</span></td>
    `,e.appendChild(a)})}}const ht=[{bg:"#EDE9FE",color:"#5B21B6"},{bg:"#CCFBF1",color:"#0F766E"},{bg:"#DBEAFE",color:"#1D4ED8"},{bg:"#FFE4E6",color:"#BE123C"},{bg:"#FEF3C7",color:"#92400E"},{bg:"#D1FAE5",color:"#065F46"}],Wt=["gold","silver","bronze","plain"],Gt=["1","2","3","4"];function nt(t,e){const o=typeof e=="string"?s(e):e;if(o){if(o.innerHTML="",!t.length){o.innerHTML='<div style="font-size:13px;color:var(--color-text-secondary)">No data yet.</div>';return}t.forEach((a,i)=>{const d=(a.name||"C").split(" ").map(p=>p[0]).join("").toUpperCase().slice(0,2),u=ht[i%ht.length],g=Wt[Math.min(i,3)],c=Gt[Math.min(i,3)],r=document.createElement("div");r.className="top-customer-row",r.innerHTML=`
      <span class="medal-dot ${g}">${c}</span>
      <span class="customer-avatar" style="background:${u.bg};color:${u.color}">${d}</span>
      <div class="top-customer-info">
        <div class="top-customer-name">${a.name||"Customer"}</div>
        <div class="top-customer-meta">${a.orders||0} orders</div>
      </div>
      <div class="top-customer-spend">${a.spend||""}</div>
    `,o.appendChild(r)})}}function Z(t){W("#booking-status-chips [data-status]").forEach(e=>{e.classList.toggle("active",e.dataset.status===t)})}async function Yt(){const t=await v("/admin/booking-summaries");if(!t.ok)return;const e=t.data?.data||{},o=e.by_status||{},a=e.total??0;W("[data-status-count]").forEach(i=>{const d=i.dataset.statusCount,u=d==="all"?a:o[d]??0;l(i,u)})}function _t(t,e){const o=Mt(e);return e==="ready"||e==="completed"?(n.bookings.steps[t]=o,o):n.bookings.steps[t]!==void 0?n.bookings.steps[t]:o!==null?(n.bookings.steps[t]=o,o):null}function Jt(t,e){return e===null?"":["Washing","Drying","Ready","Done"].map((a,i)=>`<button class="step-chip ${i===e?"active":""}" data-booking-step="${i}" data-order-id="${t}" type="button">${a}</button>`).join("")}function Kt(t,e){const o=[];return e==="pending"&&(o.push(`<button class="button-outline btn-sm btn-success" data-booking-action="accept" data-order-id="${t}" type="button">Accept</button>`),o.push(`<button class="button-outline btn-sm btn-danger" data-booking-action="decline" data-order-id="${t}" type="button">Decline</button>`)),(e==="ongoing"||e==="ready")&&o.push(`<button class="button-outline btn-sm btn-success" data-booking-action="complete" data-order-id="${t}" type="button">Complete</button>`),o.join("")}function Et(t){const e=String(t),o=n.bookings.byId[e];if(!o)return;n.bookings.activeOrderId=e;const a=s("#booking-modal"),i=s("#booking-modal-overlay"),d=s("#booking-modal-body"),u=s("#booking-modal-title"),g=s("#booking-modal-subtitle"),c=K(o),r=A(o.status)||"pending";u&&(u.textContent="Booking details"),g&&(g.textContent=`${c} · ${r}`),d&&(d.innerHTML=At(o)),i&&i.classList.add("show"),a&&(a.classList.add("show"),a.classList.remove("hidden"))}function Ct(){n.bookings.activeOrderId=null,s("#booking-modal-overlay")?.classList.remove("show");const t=s("#booking-modal");t&&(t.classList.remove("show"),t.classList.add("hidden"))}function yt(t){const e=t.dataset.orderId,o=t.dataset.bookingAction;o==="accept"?(n.bookings.steps[e]=0,Y(e,"ongoing")):o==="decline"?Y(e,"cancelled"):o==="complete"&&(n.bookings.steps[e]=3,Y(e,"completed"))}function xt(t){const e=t.dataset.orderId,o=Number(t.dataset.bookingStep);Number.isNaN(o)||(n.bookings.steps[e]=o,Y(e,Ft(o)))}async function q(){const t=Yt(),e=s("#bookings-filter");e&&(e.value=n.bookings.status);const o=new URLSearchParams({page:n.bookings.page.toString(),per_page:n.bookings.perPage.toString()});n.bookings.status&&n.bookings.status!=="all"&&o.set("status",n.bookings.status);const a=await v(`/admin/orders?${o.toString()}`),i=s("#bookings-table-body");if(!i)return;if(i.innerHTML="",!a.ok){i.innerHTML='<tr><td colspan="8">Unable to load bookings.</td></tr>';return}const d=a.data?.data||[],u=a.data?.pagination||{};if(n.bookings.byId={},!d.length){i.innerHTML='<tr><td colspan="8">No bookings found.</td></tr>',await t,Z(n.bookings.status);return}d.forEach(m=>{const h=m.order_id||m.id,y=String(h);n.bookings.byId[y]=m;const b=A(m.status);_t(h,b);const $=document.createElement("tr"),S=(m.customer_name||"Customer").split(" ").map(P=>P[0]).join("").substring(0,2).toUpperCase(),C=_(m.created_at),D=K(m),M=[{bg:"#EEEDFE",color:"#3C3489"},{bg:"#E1F5EE",color:"#085041"},{bg:"#E6F1FB",color:"#0C447C"}],F=M[(m.customer_id||0)%M.length];$.innerHTML=`
      <td><span class="order-id">${D}</span></td>
      <td>
        <div class="order-customer-cell">
          <span class="order-customer-avatar" style="background:${F.bg};color:${F.color}">${S}</span>
          <span class="order-customer-name">${m.customer_name||"Unknown"}</span>
        </div>
      </td>
      <td>${m.service_type||"Service"}</td>
      <td>${m.weight_kg||0} kg</td>
      <td>${L(m.total_price||0)}</td>
      <td>
        <span class="status-pill" data-status="${b}">
          <span class="status-dot"></span>
          ${b}
        </span>
      </td>
      <td><span class="order-created-date">${C}</span></td>
      <td>
        <div style="display:flex; gap:6px; align-items:center;">
          <button class="btn-action-pill btn-action-details" data-booking-toggle="${h}" type="button">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            Details
          </button>
          <button class="btn-action-pill btn-action-receipt" data-cod-receipt-id="${h}" type="button">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
            Receipt
          </button>
        </div>
      </td>
    `,i.appendChild($)});const g=u.total||d.length;l("#bookings-footer-info",`Showing ${d.length} of ${g} orders — Page ${u.current_page||1} of ${u.last_page||1}`);const c=s("#bookings-prev"),r=s("#bookings-next"),p=s("#bookings-current-page");c&&(c.disabled=(u.current_page||1)<=1),r&&(r.disabled=(u.current_page||1)>=(u.last_page||1)),p&&(p.textContent=u.current_page||1),await t,Z(n.bookings.status)}async function Y(t,e){const o=String(t),a=await v(`/admin/orders/${t}/status`,{method:"PATCH",body:{status:e}});if(!a.ok){w("Unable to update status.");return}w("Order status updated.");const i=a.data?.data;await q(),i&&(n.bookings.byId[o]=i),n.bookings.activeOrderId===o&&Et(t)}async function J(){const t=new URLSearchParams({page:n.customers.page.toString(),per_page:n.customers.perPage.toString()});n.customers.search&&t.set("search",n.customers.search);const e=await v(`/admin/customers?${t.toString()}`,{timeoutMs:2e4}),o=s("#customers-table-body");if(!o)return;if(o.innerHTML="",!e.ok){o.innerHTML='<tr><td colspan="6">Unable to load customers.</td></tr>';return}const a=e.data?.data||[],i=e.data?.pagination||{};a.length||(o.innerHTML='<tr><td colspan="6">No customers found.</td></tr>'),a.forEach(g=>{const c=document.createElement("tr");c.innerHTML=`
      <td>
        <div class="font-semibold">${g.name||"Customer"}</div>
        <div class="text-xs text-slate-500">${g.email||""}</div>
      </td>
      <td>${g.phone||"---"}</td>
      <td>${g.orders_count||0}</td>
      <td>${L(g.total_spent||0)}</td>
      <td>${g.loyalty_points||0}</td>
      <td>
        <button class="button-outline" data-customer-id="${g.id}">View</button>
      </td>
    `,o.appendChild(c)}),l("#customers-page-info",`Page ${i.current_page||1} of ${i.last_page||1}`);const d=s("#customers-prev"),u=s("#customers-next");d&&(d.disabled=(i.current_page||1)<=1),u&&(u.disabled=(i.current_page||1)>=(i.last_page||1))}async function Qt(t){n.currentCustomerId=t,s("#customer-drawer")?.classList.add("open"),s("#drawer-overlay")?.classList.add("show"),l("#customer-drawer-title","Loading...");const e=await v(`/admin/customers/${t}`);if(!e.ok){w("Unable to load customer.");return}const o=e.data?.data||{};l("#customer-drawer-title",o.name||"Customer"),s("#customer-name").value=o.name||"",s("#customer-email").value=o.email||"",s("#customer-phone").value=o.phone||"",s("#customer-address").value=o.address||"",s("#customer-city").value=o.city||"",s("#customer-zip").value=o.zip_code||"",s("#customer-country").value=o.country||"",s("#customer-notifications").checked=o.notifications_enabled!==!1,l("#customer-loyalty",o.loyalty_points||0),l("#customer-orders-count",o.orders_count||0),l("#customer-total-spent",L(o.total_spent||0)),l("#customer-dob",I(_(o.date_of_birth))),l("#customer-gender",I(o.gender)),l("#customer-language",I(o.preferred_language)),l("#customer-email-verified",mt(!!o.email_verified_at)),l("#customer-profile-completed",mt(!!o.profile_completed_at)),l("#customer-member-since",I(_(o.created_at))),l("#customer-last-login",I(_(o.last_login_at))),l("#customer-bio",I(o.bio)),n.customerOrders.page=1,n.customerOrders.lastPage=1,await St(!0)}function kt(){s("#customer-drawer")?.classList.remove("open"),s("#drawer-overlay")?.classList.remove("show"),n.currentCustomerId=null}async function Xt(){if(!n.currentCustomerId)return;const t={name:s("#customer-name").value.trim(),phone:s("#customer-phone").value.trim()||null,address:s("#customer-address").value.trim()||null,city:s("#customer-city").value.trim()||null,zip_code:s("#customer-zip").value.trim()||null,country:s("#customer-country").value.trim()||null,notifications_enabled:s("#customer-notifications").checked};if(!(await v(`/admin/customers/${n.currentCustomerId}`,{method:"PUT",body:t})).ok){w("Unable to update customer.");return}w("Customer updated."),await J()}async function St(t=!1){if(!n.currentCustomerId)return;t&&(n.customerOrders.page=1);const e=new URLSearchParams({page:n.customerOrders.page.toString(),per_page:n.customerOrders.perPage.toString()}),o=await v(`/admin/customers/${n.currentCustomerId}/orders?${e.toString()}`),a=s("#customer-orders-body");if(!a)return;if(!o.ok){t&&(a.innerHTML='<tr><td colspan="5">Unable to load orders.</td></tr>');return}const i=o.data?.data||[],d=o.data?.pagination||{};t&&(a.innerHTML=""),!i.length&&t&&(a.innerHTML='<tr><td colspan="5">No orders yet.</td></tr>'),i.forEach(r=>{const p=document.createElement("tr");p.innerHTML=`
      <td>${r.id||""}</td>
      <td>${r.service_type||""}</td>
      <td>${r.weight_kg||0} kg</td>
      <td>${L(r.total_price||0)}</td>
      <td>${r.status||""}</td>
    `,a.appendChild(p)}),n.customerOrders.lastPage=d.last_page||1;const u=d.current_page||n.customerOrders.page;l("#customer-orders-page-info",`Page ${u} of ${n.customerOrders.lastPage}`);const g=Number.isFinite(d.total)?d.total:i.length;l("#customer-orders-title-count",`(${g})`);const c=s("#customer-orders-load");if(c){const r=u>=n.customerOrders.lastPage;c.disabled=r,c.classList.toggle("hidden",r||g===0)}}async function Zt(){const t=await v("/admin/analytics",{timeoutMs:2e4});if(!t.ok){w("Unable to load analytics.");return}const e=t.data||{},o=Number(e.monthly_revenue||0),a=Number(e.total_orders_this_month||0),i=Number(e.completed_orders_this_month||0),d=Number(e.cancelled_orders_this_month||0),u=Number(e.new_customers_this_month||0),g=Number(e.total_customers||0),c=Number(e.completion_rate||0),r=e.top_service||null,p=Array.isArray(e.top_customers)?e.top_customers:[],m=p[0]||null;l("#analytics-month",e.month_label||""),l("#analytics-monthly-revenue",L(o)),l("#analytics-monthly-card",L(o)),l("#analytics-completion-rate",`${c}%`),l("#analytics-monthly-orders",a),l("#analytics-new-customers",u),l("#analytics-total-customers",`${g} total customers`),l("#analytics-completed-orders",i),l("#analytics-cancelled-orders",`${d} cancelled`),l("#analytics-top-service",r?.name||"No service data yet"),l("#analytics-top-service-meta",r?`${r.orders||0} orders`:"No completed order mix yet"),l("#analytics-top-customer",m?.name||"No customer data yet"),l("#analytics-top-customer-meta",m?`${m.orders||0} orders · ${m.spend_label||L(m.spend||0)}`:"No customer orders yet"),l("#analytics-order-health",`${c}% completion`);const h=e.weekly_revenue||[],y=Math.max(1,...h.map(x=>Number(x||0))),b=["Mon","Tue","Wed","Thu","Fri","Sat","Sun"],$=s("#weekly-bars");if(!$)return;$.innerHTML="",h.forEach((x,N)=>{const E=Math.round(Number(x||0)/y*100),T=document.createElement("div");T.className="weekly-bar",T.innerHTML=`
      <div class="weekly-bar-value">${L(Number(x||0))}</div>
      <div class="weekly-bar-track" title="${L(Number(x||0))}">
        <div class="weekly-bar-fill" style="height:${E}%;"></div>
      </div>
      <div class="weekly-bar-label">${b[N]||""}</div>
    `,$.appendChild(T)});const S=e.service_breakdown||[],C=s("#service-breakdown-body"),D=s("#service-breakdown-donut"),M=s("#service-breakdown-total");C&&(C.innerHTML="");const F=["#3B82F6","#34D399","#F59E0B","#EC4899","#A78BFA","#22D3EE"];let P=0,z=0;const B=[];if(!S.length)C&&(C.innerHTML='<div class="analytics-empty">No service data yet.</div>'),D&&(D.style.background="conic-gradient(rgba(148, 163, 184, 0.2) 0% 100%)"),M&&l("#service-breakdown-total","0%");else if(S.forEach((x,N)=>{const E=Math.max(0,Math.min(100,Number(x.pct||0))),T=F[N%F.length];if(E>0&&B.push(`${T} ${P}% ${P+E}%`),P+=E,z+=E,C){const U=document.createElement("div");U.className="breakdown-legend-row",U.innerHTML=`
          <span class="breakdown-legend-swatch" style="background:${T};"></span>
          <div class="breakdown-legend-copy">
            <div class="breakdown-legend-name">${R(x.name||"Service")}</div>
            <div class="breakdown-legend-meta">${E}% &middot; ${x.count||0} orders</div>
          </div>
        `,C.appendChild(U)}}),D){const x=Math.min(100,Math.round(z));z<100&&B.push(`rgba(148, 163, 184, 0.2) ${z}% 100%`),D.style.background=`conic-gradient(${B.join(", ")})`,M&&l("#service-breakdown-total",`${x}%`)}const H=s("#analytics-top-customers-list");H&&(H.innerHTML="",p.length?p.forEach((x,N)=>{const E=document.createElement("div");E.className="analytics-customer-row",E.innerHTML=`
          <span class="analytics-rank">${N+1}</span>
          <div class="analytics-customer-copy">
            <strong>${R(x.name||"Customer")}</strong>
            <span>${x.orders||0} orders</span>
          </div>
          <div class="analytics-customer-spend">${x.spend_label||L(x.spend||0)}</div>
        `,H.appendChild(E)}):H.innerHTML='<div class="analytics-empty">No customer spend data yet.</div>')}async function dt(){const[t,e]=await Promise.all([v("/admin/services"),v("/admin/top-customers")]),o=s("#services-table-body");if(!o)return;if(o.innerHTML="",!t.ok){o.innerHTML='<tr><td colspan="6">Unable to load services.</td></tr>',nt(e.ok?e.data?.data||[]:[],"#services-top-customers-body");return}const a=t.data?.data||[];a.length||(o.innerHTML='<tr><td colspan="6">No services found.</td></tr>'),a.forEach(i=>{const d=document.createElement("tr");d.innerHTML=`
      <td>
        <div class="font-semibold">${i.name||"Service"}</div>
        <div class="text-xs text-slate-500">${i.description||""}</div>
      </td>
      <td>${L(i.price_per_kg||0)}</td>
      <td>${i.category||"---"}</td>
      <td>${i.is_active?"Active":"Inactive"}</td>
      <td class="space-x-2">
        <button class="button-outline" data-edit-service="${i.id}">Edit</button>
        <button class="button-outline" data-delete-service="${i.id}">Delete</button>
      </td>
    `,o.appendChild(d)}),nt(e.ok?e.data?.data||[]:[],"#services-top-customers-body")}async function te(){const t={name:s("#service-name").value.trim(),description:s("#service-description").value.trim()||null,price_per_kg:Number(s("#service-price").value||0),category:s("#service-category").value.trim()||null,image_url:s("#service-image").value.trim()||null,is_active:s("#service-active").checked},e=n.services.editingId;if(!(await v(`/admin/services${e?`/${e}`:""}`,{method:e?"PUT":"POST",body:t})).ok){w("Unable to save service.");return}w(e?"Service updated.":"Service created."),Dt(),await dt()}function Dt(){n.services.editingId=null,l("#service-form-title","Create service"),s("#service-name").value="",s("#service-description").value="",s("#service-price").value="",s("#service-category").value="",s("#service-image").value="",s("#service-active").checked=!0}async function ee(t){const e=await v("/admin/services");if(!e.ok)return;const a=(e.data?.data||[]).find(i=>i.id===Number(t));a&&(n.services.editingId=a.id,l("#service-form-title","Update service"),s("#service-name").value=a.name||"",s("#service-description").value=a.description||"",s("#service-price").value=a.price_per_kg||"",s("#service-category").value=a.category||"",s("#service-image").value=a.image_url||"",s("#service-active").checked=a.is_active!==!1)}async function oe(t){if(!window.confirm("Delete this service?"))return;if(!(await v(`/admin/services/${t}`,{method:"DELETE"})).ok){w("Unable to delete service.");return}w("Service deleted."),await dt()}function wt(t,e,o){t.type=o?"text":"password",e.setAttribute("aria-pressed",o?"true":"false"),e.setAttribute("aria-label",o?"Hide password":"Show password"),e.innerHTML=o?'<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>':'<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>'}function se(){const t=s("#login-form");t&&t.addEventListener("submit",It);const e=s("#toggle-password"),o=s("#login-password");e&&o&&(wt(o,e,!1),e.addEventListener("click",()=>{const f=o.type==="password";wt(o,e,f)}));const a=s("#logout-button");a&&a.addEventListener("click",Rt);const i=s("#logout-modal-cancel");i&&i.addEventListener("click",vt);const d=s("#logout-modal-confirm");d&&d.addEventListener("click",Ut);const u=s("#logout-modal-overlay");u&&u.addEventListener("click",vt),W("[data-view]").forEach(f=>{f.addEventListener("click",()=>{at(f.dataset.view),bt()})});const g=s("#bookings-filter");g&&g.addEventListener("change",f=>{n.bookings.status=f.target.value,n.bookings.page=1,Z(n.bookings.status),q()});const c=s("#booking-status-chips");c&&c.addEventListener("click",f=>{const k=f.target.closest("[data-status]");k&&(n.bookings.status=k.dataset.status,n.bookings.page=1,Z(n.bookings.status),g&&(g.value=n.bookings.status),q())});const r=s("#bookings-prev");r&&r.addEventListener("click",()=>{n.bookings.page=Math.max(1,n.bookings.page-1),q()});const p=s("#bookings-next");p&&p.addEventListener("click",()=>{n.bookings.page+=1,q()});const m=s("#bookings-table-body");m&&(m.addEventListener("change",f=>{const k=f.target.closest("select[data-order-id]");k&&Y(k.dataset.orderId,k.value)}),m.addEventListener("click",f=>{const k=f.target.closest("[data-cod-receipt-id]");if(k){const tt=k.dataset.codReceiptId,gt=n.bookings.byId[String(tt)];gt?ae(gt):w("Receipt data unavailable. Please refresh.");return}const O=f.target.closest("[data-booking-toggle]");if(O){const tt=O.dataset.bookingToggle;Et(tt);return}const ut=f.target.closest("[data-booking-action]");if(ut){yt(ut);return}const pt=f.target.closest("[data-booking-step]");pt&&xt(pt)}));const h=s("#booking-modal-close");h&&h.addEventListener("click",Ct);const y=s("#booking-modal");y&&y.addEventListener("click",f=>{const k=f.target.closest("[data-booking-action]");if(k){yt(k);return}const O=f.target.closest("[data-booking-step]");O&&xt(O)});const b=s("#customers-search-button");b&&b.addEventListener("click",()=>{n.customers.search=s("#customers-search-input").value.trim(),n.customers.page=1,J()});const $=s("#customers-prev");$&&$.addEventListener("click",()=>{n.customers.page=Math.max(1,n.customers.page-1),J()});const S=s("#customers-next");S&&S.addEventListener("click",()=>{n.customers.page+=1,J()});const C=s("#customers-table-body");C&&C.addEventListener("click",f=>{const k=f.target.closest("[data-customer-id]");k&&Qt(k.dataset.customerId)});const D=s("#customer-drawer-close");D&&D.addEventListener("click",kt);const M=s("#drawer-overlay");M&&M.addEventListener("click",kt);const F=s("#customer-save");F&&F.addEventListener("click",Xt);const P=s("#customer-orders-load");P&&P.addEventListener("click",()=>{n.customerOrders.page>=n.customerOrders.lastPage||(n.customerOrders.page+=1,St())});const z=s("#service-save");z&&z.addEventListener("click",te);const B=s("#service-clear");B&&B.addEventListener("click",Dt);const H=s("#services-table-body");H&&H.addEventListener("click",f=>{const k=f.target.closest("[data-edit-service]");if(k){ee(k.dataset.editService);return}const O=f.target.closest("[data-delete-service]");O&&oe(O.dataset.deleteService)});const x=s("#recent-orders-view-all");x&&x.addEventListener("click",()=>at("bookings"));const N=s("#sidebar-toggle");N&&N.addEventListener("click",zt);const E=s("#sidebar-overlay");E&&E.addEventListener("click",bt);const T=s("#cod-receipt-close");T&&T.addEventListener("click",ot);const U=s("#cod-receipt-cancel");U&&U.addEventListener("click",ot);const ct=s("#cod-receipt-print");ct&&ct.addEventListener("click",ne);const lt=s("#cod-receipt-overlay");lt&&lt.addEventListener("click",ot)}window.addEventListener("DOMContentLoaded",()=>{se(),Ht()});function ae(t){const e=s("#cod-receipt-modal"),o=s("#cod-receipt-overlay"),a=s("#cod-receipt-body");if(!e||!o||!a)return;const i=K(t),d=it(t.delivery_type),u=_(t.pickup_date),g=_(t.delivery_date),c=_(t.created_at),r=L(t.total_price||0),p=new Date().toLocaleDateString("en-PH",{month:"short",day:"numeric",year:"numeric"}),m=(h,y,b="")=>`
    <tr>
      <td style="padding:9px 12px; color:#58708D; font-size:12px; font-weight:500; width:42%; white-space:nowrap; vertical-align:middle;">
        ${b?`<span style="margin-right:5px; opacity:0.7;">${b}</span>`:""}${h}
      </td>
      <td style="padding:9px 12px; color:#08213D; font-size:12.5px; font-weight:600; vertical-align:middle;">${y}</td>
    </tr>`;a.innerHTML=`
    <div id="cod-receipt-print-area" style="font-family:'Segoe UI',Arial,sans-serif; color:#08213D; background:#fff;">

      <!-- Branded Header -->
      <div style="background:linear-gradient(135deg,#1565C0 0%,#0D47A1 100%); padding:22px 24px 20px; text-align:center; position:relative; overflow:hidden;">
        <div style="position:absolute;top:-18px;right:-18px;width:90px;height:90px;border-radius:50%;background:rgba(255,255,255,0.07);"></div>
        <div style="position:absolute;bottom:-24px;left:-12px;width:70px;height:70px;border-radius:50%;background:rgba(255,255,255,0.05);"></div>
        <div style="font-size:10px; font-weight:800; letter-spacing:0.22em; text-transform:uppercase; color:rgba(255,255,255,0.65); margin-bottom:6px;">LaundryHub</div>
        <div style="font-size:24px; font-weight:800; color:#fff; letter-spacing:-0.5px; margin-bottom:4px;">Cash on Delivery Receipt</div>
        <div style="display:inline-block; background:rgba(255,255,255,0.15); border-radius:20px; padding:3px 14px; font-size:12px; font-weight:700; color:#fff; letter-spacing:0.05em;">${i}</div>
        <div style="margin-top:6px; font-size:11px; color:rgba(255,255,255,0.55);">Issued: ${p}</div>
      </div>

      <!-- Detail Rows -->
      <div style="padding:4px 0;">
        <table style="width:100%; border-collapse:collapse;">
          <tbody>
            <tr style="background:#F8FBFF;">
              <td colspan="2" style="padding:7px 12px; font-size:10px; font-weight:800; letter-spacing:0.12em; text-transform:uppercase; color:#58708D;">Customer Info</td>
            </tr>
            ${m("Customer",R(t.customer_name||"N/A"),"👤")}
            ${m("Address",R(t.pickup_address||"N/A"),"📍")}
            <tr style="background:#F8FBFF;">
              <td colspan="2" style="padding:7px 12px; font-size:10px; font-weight:800; letter-spacing:0.12em; text-transform:uppercase; color:#58708D;">Order Details</td>
            </tr>
            ${m("Service",R(t.service_type||"---"),"🧺")}
            ${m("Weight",`${t.weight_kg||0} kg`,"⚖️")}
            ${m("Fulfillment",d,"🚚")}
            ${m("Pickup Date",u,"📅")}
            ${m("Delivery Date",g,"📅")}
            ${m("Order Date",c,"🗓️")}
          </tbody>
        </table>
      </div>

      <!-- Total Banner -->
      <div style="margin:0 16px 16px; background:linear-gradient(135deg,#EEF4FF 0%,#E8F0FE 100%); border:1px solid rgba(21,101,192,0.18); border-radius:10px; padding:16px 20px; display:flex; align-items:center; justify-content:space-between;">
        <div>
          <div style="font-size:10px; font-weight:700; letter-spacing:0.10em; text-transform:uppercase; color:#58708D; margin-bottom:2px;">Total Amount Due</div>
          <div style="font-size:26px; font-weight:800; color:#1565C0; letter-spacing:-0.5px;">${r}</div>
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
  `,e.classList.remove("hidden"),e.classList.add("show"),o.classList.add("show")}function ot(){const t=s("#cod-receipt-modal"),e=s("#cod-receipt-overlay");t&&(t.classList.remove("show"),t.classList.add("hidden")),e&&e.classList.remove("show")}function ne(){const t=s("#cod-receipt-modal");if(!t||t.classList.contains("hidden")){w("Open a receipt first.");return}const e=Array.from(t.querySelectorAll("#cod-receipt-print-area table tbody tr")).filter(b=>!b.querySelector("[colspan]")).map(b=>{const $=b.querySelectorAll("td");if($.length<2)return null;const S=$[0].textContent.replace(/[\u{1F000}-\u{1FFFF}]/gu,"").trim(),C=$[1].textContent.trim();return{label:S,value:C}}).filter(Boolean);t.querySelector(".btn-action-receipt")?.dataset?.codReceiptId;const o=t.querySelector("#cod-receipt-print-area > div:first-child"),a=o?o.querySelectorAll("div"):[],i=a[2]?.textContent?.trim()||"",d=a[3]?.textContent?.trim()||"",g=t.querySelector('#cod-receipt-print-area [style*="font-size:26px"]')?.textContent?.trim()||"";e.map(({label:b,value:$})=>`
    <tr>
      <td class="label-col">${b}</td>
      <td class="value-col">${$}</td>
    </tr>`).join("");const c=["Customer","Address"],r=e.filter(b=>c.includes(b.label)),p=e.filter(b=>!c.includes(b.label)),m=b=>b.map(({label:$,value:S})=>`
    <tr>
      <td class="label">${$}</td>
      <td class="value">${S}</td>
    </tr>`).join(""),h=`<!DOCTYPE html>
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
      <div class="issued">${d}</div>
    </div>

    <div class="section">
      <div class="section-head">Customer Information</div>
      <table>
        ${m(r)}
      </table>

      <div class="section-head">Order Details</div>
      <table>
        ${m(p)}
      </table>
    </div>

    <div class="total-box">
      <div>
        <div class="total-label">Total Amount Paid</div>
        <div class="total-amount">${g}</div>
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
</html>`,y=window.open("","_blank","width=680,height=860");if(!y){w("Allow pop-ups to print/save this receipt.");return}y.document.open(),y.document.write(h),y.document.close(),y.onload=()=>{y.focus(),y.print()}}function ie(){const t=document.getElementById("report-filter")?.value||"all";let e=Object.values(n.bookings.byId||{});if(t!=="all"&&(e=e.filter(r=>A(r.status)===t)),!e.length){w("No orders available to export.");return}const o=["Order ID","Customer Name","Service Type","Delivery Type","Weight (kg)","Total Price","Status","Pickup Date","Delivery Date","Pickup Address","Created At"],a=r=>{const p=String(r??"").trim();return p.includes(",")||p.includes('"')||p.includes(`
`)?`"${p.replace(/"/g,'""')}"`:p},i=e.map(r=>[a(K(r)),a(r.customer_name||"N/A"),a(r.service_type||"N/A"),a(it(r.delivery_type)),r.weight_kg||0,r.total_price||0,a(A(r.status)),a(_(r.pickup_date)),a(_(r.delivery_date)),a(r.pickup_address||"N/A"),a(_(r.created_at))]),d=[o.join(","),...i.map(r=>r.join(","))].join(`
`),u=new Blob([d],{type:"text/csv;charset=utf-8;"}),g=URL.createObjectURL(u),c=document.createElement("a");c.href=g,c.setAttribute("download",`LaundryHub_Master_Report_${t}_${new Date().toISOString().split("T")[0]}.csv`),document.body.appendChild(c),c.click(),document.body.removeChild(c)}function re(){const t=document.getElementById("report-filter")?.value||"all";let e=Object.values(n.bookings.byId||{});if(t!=="all"&&(e=e.filter(c=>A(c.status)===t)),!e.length){w("No data to export.");return}const o=e.reduce((c,r)=>c+Number(r.total_price||0),0),a=e.reduce((c,r)=>c+Number(r.weight_kg||0),0),i={};e.forEach(c=>{const r=c.service_type||"General";i[r]=(i[r]||0)+1});const d=window.open("","_blank","width=1000,height=1200");if(!d)return;const u=e.map(c=>`
    <tr>
      <td style="font-family:monospace; font-size:11px;">${K(c)}</td>
      <td style="font-weight:600;">${R(c.customer_name||"N/A")}</td>
      <td>${R(c.service_type||"N/A")}</td>
      <td>${c.weight_kg||0}kg</td>
      <td style="font-weight:700; color:#1e40af;">${L(c.total_price||0)}</td>
      <td><span class="status-badge ${A(c.status)}">${A(c.status)}</span></td>
      <td style="color:#64748b; font-size:11px;">${_(c.created_at)}</td>
    </tr>
  `).join(""),g=Object.entries(i).sort((c,r)=>r[1]-c[1]).map(([c,r])=>`
      <div class="service-stat">
        <span class="service-name">${c}</span>
        <span class="service-count">${r} orders</span>
      </div>
    `).join("");d.document.write(`
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <title>LaundryHub Executive Report</title>
        <style>
          @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');
          body { font-family: 'Plus Jakarta Sans', sans-serif; color: #1e293b; padding: 40px; line-height: 1.6; background: #fff; }
          
          .no-print-bar { background:#1e40af; color:#fff; padding:12px 24px; border-radius:12px; margin-bottom:30px; display:flex; justify-content:space-between; align-items:center; box-shadow: 0 4px 12px rgba(30,64,175,0.2); }
          .print-btn { background:#fff; color:#1e40af; border:none; padding:8px 20px; border-radius:8px; font-weight:700; cursor:pointer; }
          
          .header-main { display: flex; justify-content: space-between; border-bottom: 3px solid #1e40af; padding-bottom: 24px; margin-bottom: 32px; }
          .brand-box h1 { margin: 0; font-size: 32px; font-weight: 800; color: #1e40af; letter-spacing: -0.04em; }
          .brand-box p { margin: 0; font-size: 14px; font-weight: 600; color: #64748b; }
          
          .meta-box { text-align: right; }
          .meta-box h2 { margin: 0; font-size: 14px; font-weight: 800; text-transform: uppercase; color: #1e40af; }
          .meta-box p { margin: 2px 0 0; font-size: 12px; color: #64748b; font-weight: 500; }

          .grid-summary { display: grid; grid-template-columns: 2fr 1fr; gap: 32px; margin-bottom: 32px; }
          
          .stats-panel { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
          .stat-item { background: #f8fafc; border: 1px solid #e2e8f0; padding: 16px; border-radius: 16px; }
          .stat-label { font-size: 10px; font-weight: 800; text-transform: uppercase; color: #64748b; margin-bottom: 4px; }
          .stat-value { font-size: 20px; font-weight: 800; color: #1e293b; }

          .breakdown-panel { background: #eff6ff; border-radius: 16px; padding: 16px; }
          .breakdown-title { font-size: 11px; font-weight: 800; text-transform: uppercase; color: #1e40af; margin-bottom: 12px; }
          .service-stat { display: flex; justify-content: space-between; font-size: 12px; margin-bottom: 6px; padding-bottom: 6px; border-bottom: 1px solid rgba(30,64,175,0.1); }
          .service-name { font-weight: 600; }
          
          table { width: 100%; border-collapse: collapse; margin-top: 16px; }
          th { text-align: left; padding: 12px; font-size: 10px; font-weight: 800; text-transform: uppercase; color: #64748b; background: #f8fafc; border-bottom: 2px solid #e2e8f0; }
          td { padding: 12px; border-bottom: 1px solid #f1f5f9; font-size: 12px; }
          
          .status-badge { display: inline-block; padding: 2px 8px; border-radius: 6px; font-size: 9px; font-weight: 800; text-transform: uppercase; }
          .status-badge.completed { background: #dcfce7; color: #166534; }
          .status-badge.pending { background: #fef3c7; color: #92400e; }
          .status-badge.ready { background: #dbeafe; color: #1e40af; }
          
          .signature-section { margin-top: 60px; display: grid; grid-template-columns: repeat(2, 1fr); gap: 100px; }
          .sig-box { border-top: 1px solid #1e293b; padding-top: 8px; text-align: center; }
          .sig-label { font-size: 11px; font-weight: 700; color: #1e293b; }
          .sig-date { font-size: 10px; color: #64748b; }

          .footer-note { margin-top: 48px; text-align: center; font-size: 10px; color: #94a3b8; border-top: 1px solid #f1f5f9; padding-top: 16px; }
          @media print { .no-print-bar { display: none; } body { padding: 0; } }
        </style>
      </head>
      <body>
        <div class="no-print-bar">
          <span>Executive Business Report Ready</span>
          <button class="print-btn" onclick="window.print()">Download PDF</button>
        </div>

        <div class="header-main">
          <div class="brand-box">
            <h1>LaundryHub</h1>
            <p>Operations & Analytics Unit</p>
          </div>
          <div class="meta-box">
            <h2>Management Report</h2>
            <p>Scope: ${t.toUpperCase()}</p>
            <p>Ref: LH-REP-${new Date().getTime().toString().slice(-6)}</p>
            <p>${new Date().toLocaleDateString("en-PH",{month:"long",day:"numeric",year:"numeric"})}</p>
          </div>
        </div>

        <div class="grid-summary">
          <div class="stats-panel">
            <div class="stat-item">
              <div class="stat-label">Total Transactions</div>
              <div class="stat-value">${e.length}</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">Processed Weight</div>
              <div class="stat-value">${a.toFixed(1)}kg</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">Gross Revenue</div>
              <div class="stat-value">${L(o)}</div>
            </div>
          </div>
          <div class="breakdown-panel">
            <div class="breakdown-title">Service Performance</div>
            ${g}
          </div>
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
              <th>Date</th>
            </tr>
          </thead>
          <tbody>
            ${u}
          </tbody>
        </table>

        <div class="signature-section">
          <div class="sig-box">
            <div class="sig-label">Prepared By</div>
            <div class="sig-date">${n.user?.name||"Admin"}</div>
          </div>
          <div class="sig-box">
            <div class="sig-label">Verified By</div>
            <div class="sig-date">Management / Audit</div>
          </div>
        </div>

        <div class="footer-note">
          This document is generated automatically by the LaundryHub Management System. 
          Confidential - Internal Use Only. &copy; ${new Date().getFullYear()} LaundryHub Management System &bull; Confidential &bull; Generated by Admin
        </div>
      </body>
    </html>
  `),d.document.close(),d.onload=()=>{d.focus(),d.print()}}document.addEventListener("DOMContentLoaded",()=>{const t=document.getElementById("btn-download-csv"),e=document.getElementById("btn-download-pdf");t&&t.addEventListener("click",ie),e&&e.addEventListener("click",re)});
