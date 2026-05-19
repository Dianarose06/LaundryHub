import"./app-UyRVujZY.js";const o={token:null,user:null,isLoginSubmitting:!1,isLogoutSubmitting:!1,view:"dashboard",bookings:{page:1,perPage:20,status:"all",search:"",steps:{},byId:{},activeOrderId:null},customers:{page:1,perPage:20,search:""},services:{editingId:null,items:[],search:""},customerOrders:{page:1,perPage:10,lastPage:1},analytics:{weekOffset:0,startDate:"",endDate:""},currentCustomerId:null},Xe={dashboard:"Dashboard",bookings:"Bookings",customers:"Customers",analytics:"Analytics and Reports",services:"Services"},je=new Set(Object.keys(Xe)),a=(e,t=document)=>t.querySelector(e),te=(e,t=document)=>Array.from(t.querySelectorAll(e)),X=`${window.LAUNDRYHUB_API_BASE_URL||"/api"}`.trim().replace(/\/$/,""),et=(()=>{if(!X)return"/api";if(X.startsWith("/"))return X;if(!X.startsWith("http"))return`/${X.replace(/^\/+/,"")}`;try{return new URL(X,window.location.origin).pathname.replace(/\/$/,"")||"/api"}catch{return"/api"}})();function u(e,t){const s=typeof e=="string"?a(e):e;s&&(s.classList.remove("skeleton"),s.textContent=t)}function N(e="100%",t="md"){return`<div class="skeleton skeleton-line ${t}" style="width:${e};"></div>`}function w(e,t="70%",s="lg"){const n=a(e);n&&(n.innerHTML=N(t,s))}function le(e,t,s=4){const n=a(e);if(!n)return;const r=Array.from({length:s}).map(()=>`
    <tr class="skeleton-row">
      ${Array.from({length:t}).map(()=>`<td>${N("100%","sm")}</td>`).join("")}
    </tr>
  `).join("");n.innerHTML=r}function Ve(e,t=4){const s=a(e);s&&(s.innerHTML=Array.from({length:t}).map(()=>`
    <div class="top-customer-row">
      <span class="skeleton skeleton-avatar"></span>
      <div class="top-customer-info">
        <div>${N("70%","sm")}</div>
        <div style="margin-top:6px;">${N("40%","sm")}</div>
      </div>
      <div style="width:80px;">${N("100%","sm")}</div>
    </div>
  `).join(""))}function V(e){e&&e.classList.remove("hidden")}function K(e){e&&e.classList.add("hidden")}function $(e){const t=a("#toast");t&&(t.textContent=e,t.classList.add("show"),t.setAttribute("aria-hidden","false"),setTimeout(()=>{t.classList.remove("show"),t.setAttribute("aria-hidden","true")},3e3))}function C(e){return`PHP ${Number(e||0).toLocaleString("en-PH",{maximumFractionDigits:0})}`}function D(e){if(!e)return"---";const t=new Date(e);return Number.isNaN(t.getTime())?e:t.toLocaleDateString("en-PH",{month:"short",day:"numeric",year:"numeric"})}function tt(e,t){if(!e||!t)return"Mon-Sun";const s=new Date(`${e}T00:00:00`),n=new Date(`${t}T00:00:00`);if(Number.isNaN(s.getTime())||Number.isNaN(n.getTime()))return"Mon-Sun";const r=i=>i.toLocaleDateString("en-PH",{month:"short",day:"numeric"});return`${r(s)}-${r(n)}`}function Y(e,t="---"){return e==null||e===""?t:e}function O(e){return`${e??""}`.replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;").replaceAll('"',"&quot;").replaceAll("'","&#039;")}function Me(e){return e?"Yes":"No"}function ve(e){return`${e||""}`.trim().toLowerCase()}function I(e){return(e||"").toString().toLowerCase()}function se(e){const t=I(e)||"pickup";return t==="delivery"||t==="dropoff"?"Drop-off":"Pickup"}function Pe(e){return`PHP ${Number(e||0).toLocaleString("en-PH",{minimumFractionDigits:2,maximumFractionDigits:2})}`}function st(e){const t=I(e?.type||e?.delivery_type);return t!=="delivery"&&t!=="dropoff"}function ae(e){const t=e?.id??e?.order_id??"",s=String(t).replace(new RegExp("^#?LH-+"),"");return s?`#LH-${s.padStart(3,"0")}`:String(t||"---")}function at(e){const t=e.order_id||e.id,s=I(e.status),n=Ye(t,s),r=D(e.pickup_date),i=D(e.delivery_date||e.pickup_date),l=se(e.type||e.delivery_type),p=st(e),d=Y(e.pickup_address),c=p?"PHP 50.00":"PHP 0.00 (No delivery fee)",m=e.laundry_photo_url||e.laundry_photo||"",g=D(e.updated_at),h=["ongoing","ready","completed"].includes(s)?wt(t,n):"",k=xt(t,s);return`
    <div class="details-grid">
      <div>
        <div class="details-label">Pickup date</div>
        <div class="details-value">${r}</div>
      </div>
      <div>
        <div class="details-label">Delivery date</div>
        <div class="details-value">${i}</div>
      </div>
      <div>
        <div class="details-label">Order type</div>
        <div class="details-value">${l}</div>
      </div>
      <div>
        <div class="details-label">Delivery fee</div>
        <div class="details-value">${c}</div>
      </div>
      ${p?`
      <div>
        <div class="details-label">Pickup address</div>
        <div class="details-value">${d}</div>
      </div>
      `:""}
      <div>
        <div class="details-label">Created</div>
        <div class="details-value">${D(e.created_at)}</div>
      </div>
      <div>
        <div class="details-label">Updated</div>
        <div class="details-value">${g}</div>
      </div>
    </div>
    ${p&&m?`
      <div class="details-photo">
        <div class="details-label">Laundry photo</div>
        <a href="${O(m)}" target="_blank" rel="noopener">
          <img src="${O(m)}" alt="Laundry photo for ${O(ae(e))}">
        </a>
      </div>
    `:""}
    <div class="details-actions">
      ${h?`<div class="step-chips">${h}</div>`:"<div></div>"}
      <div class="action-buttons">${k||'<span class="text-xs text-muted">No actions</span>'}</div>
    </div>
  `}function ot(e){return e==="ready"?2:e==="completed"?3:e==="ongoing"?0:null}function nt(e){return e===2?"ready":e===3?"completed":"ongoing"}function it(e){return`/admin/${e}`}function qe(e){const t=(e||"").replace(/\/+$/,"");if(t==="/admin"||t==="")return"dashboard";const s=t.replace(/^\/admin\/?/,"").split("/")[0];return je.has(s)?s:"dashboard"}function pe(e,t={}){const s=je.has(e)?e:"dashboard";if(o.view=s,te(".view-section").forEach(n=>{n.classList.toggle("hidden",n.dataset.view!==s)}),te("[data-view]").forEach(n=>{n.classList.toggle("active",n.dataset.view===s)}),t.syncUrl){const n=it(s);window.location.pathname.replace(/\/+$/,"")!==n&&(t.replaceUrl?window.history.replaceState({view:s},"",n):window.history.pushState({view:s},"",n))}bt(s).catch(n=>{console.error("Failed to load view",n)})}function We(e,t){localStorage.setItem("lh_admin_token",e),localStorage.setItem("lh_admin_user",JSON.stringify(t)),o.token=e,o.user=t}function ce(){localStorage.removeItem("lh_admin_token"),localStorage.removeItem("lh_admin_user"),o.token=null,o.user=null}function Ge(){return window.location.pathname==="/admin"}function rt(){return window.location.pathname.startsWith("/admin/")}function ue(){if(Ke(),!Ge()){window.location.assign("/admin");return}V(a(".bg-aurora")),V(a("#login-view")),K(a("#app-view"))}function ct(){if(!rt()){window.location.assign("/admin/dashboard");return}if(K(a(".bg-aurora")),K(a("#login-view")),V(a("#app-view")),dt(),o.user){const e=o.user.name?.trim()||"LaundryHub Admin",t="Admin",s=t.charAt(0).toUpperCase()||"A",n=o.user.email||"admin@laundryhub.com";u("#user-name",e),u("#user-email",o.user.email||""),u("#header-admin-name",t),u("#header-admin-avatar",s),u("#sidebar-admin-name",t),u("#sidebar-admin-email",n),u("#sidebar-admin-avatar",s)}}function dt(){te('.bg-aurora, [class*="watermark"], [id*="watermark"]').forEach(t=>{t.style.display="none"})}function Ne(){a(".sidebar")?.classList.remove("open"),a("#sidebar-overlay")?.classList.remove("show"),a("#sidebar-toggle")?.setAttribute("aria-expanded","false")}function lt(){const e=a(".sidebar"),t=a("#sidebar-overlay"),s=a("#sidebar-toggle");if(!e||!t||!s)return;const n=e.classList.toggle("open");t.classList.toggle("show",n),s.setAttribute("aria-expanded",n?"true":"false")}function Oe(e){const t=a("#login-submit"),s=a("#login-submit .btn-spinner"),n=a("#login-submit .btn-label"),r=a("#login-email"),i=a("#login-password");t&&(t.disabled=e,t.classList.toggle("is-loading",e),t.setAttribute("aria-busy",e?"true":"false")),s&&s.classList.toggle("hidden",!e),n&&(n.textContent=e?"Signing in...":"Sign in"),r&&(r.disabled=e),i&&(i.disabled=e)}function he(e){const t=a("#logout-modal-confirm"),s=a("#logout-modal-confirm .btn-spinner"),n=a("#logout-modal-confirm .btn-label"),r=a("#logout-modal-cancel");t&&(t.disabled=e,t.classList.toggle("is-loading",e),t.setAttribute("aria-busy",e?"true":"false")),s&&s.classList.toggle("hidden",!e),n&&(n.textContent=e?"Logging out...":"Yes"),r&&(r.disabled=e)}const fe=new Map;async function x(e,t={}){const s=new AbortController,n=Number.isFinite(t.timeoutMs)?t.timeoutMs:8e3,r=n>0?setTimeout(()=>s.abort(),n):null,i=t.suppressToast===!0,l=t.method||"GET";l!=="GET"&&fe.clear();const p=e+(t.body?JSON.stringify(t.body):""),d=l==="GET"&&t.cache!==!1;if(d){const m=fe.get(p);if(m&&Date.now()-m.timestamp<3e4)return m.res}const c={method:l,headers:{Accept:"application/json",...t.headers},signal:s.signal};!t.skipAuth&&o.token&&(c.headers.Authorization=`Bearer ${o.token}`),t.body&&(c.headers["Content-Type"]="application/json",c.body=JSON.stringify(t.body));try{const m=await fetch(`${et}${e}`,c);r&&clearTimeout(r);let g=null;try{g=await m.json()}catch{g=null}(m.status===401||m.status===403)&&(ce(),ue(),$("Session expired. Please sign in again."));const h={ok:m.ok,status:m.status,data:g};return d&&m.ok&&fe.set(p,{res:h,timestamp:Date.now()}),h}catch(m){return r&&clearTimeout(r),m?.name==="AbortError"?(i||$("Request timed out. The server may still be starting up."),{ok:!1,status:408,data:{message:"Request timed out."}}):(i||$("Network error. Please try again."),{ok:!1,status:0,data:null})}}async function ut(){const e=Ge(),t=localStorage.getItem("lh_admin_token"),s=localStorage.getItem("lh_admin_user");if(!t||!s){ce(),ue();return}let n=null;try{n=JSON.parse(s)}catch{ce(),ue();return}if(!n||ve(n.role)!=="admin"){ce(),ue();return}if(e){window.location.assign("/admin/dashboard");return}o.token=t,o.user=n,ct();const r=qe(window.location.pathname);pe(r,{replaceUrl:!0,syncUrl:!0}),x("/user").then(i=>{i.ok&&ve(i.data?.role)==="admin"&&We(t,i.data)}).catch(()=>{})}async function pt(e){if(e.preventDefault(),o.isLoginSubmitting)return;const t=a("#login-email")?.value.trim()||"",s=a("#login-password")?.value||"",n=a("#login-error");K(n),o.isLoginSubmitting=!0,Oe(!0);let r=!1,i;try{if(i=await x("/login",{method:"POST",body:{email:t,password:s},skipAuth:!0,timeoutMs:45e3}),!i.ok){const m=i.data?.message||`Login failed (Status: ${i.status||"Unknown"})`;u(n,m),V(n);return}const l=i.data?.user||i.data?.data?.user||null,p=`${i.data?.token||i.data?.access_token||i.data?.data?.token||i.data?.data?.access_token||""}`.trim(),d=ve(l?.role||i.data?.role||i.data?.data?.role);if(!p){u(n,"Login failed. Missing access token."),V(n);return}if(d!=="admin"){u(n,"This account does not have admin access."),V(n);return}We(p,l||{role:"admin",email:t}),r=!0,window.location.assign("/admin/dashboard")}finally{o.isLoginSubmitting=!1,r||Oe(!1)}}async function mt(){gt()}function gt(){o.isLogoutSubmitting||(he(!1),a("#logout-modal-overlay")?.classList.add("show"),a("#logout-modal")?.classList.remove("hidden"),a("#logout-modal")?.classList.add("show"))}function Ie(){o.isLogoutSubmitting||(he(!1),a("#logout-modal-overlay")?.classList.remove("show"),a("#logout-modal")?.classList.remove("show"),a("#logout-modal")?.classList.add("hidden"))}async function ft(){if(!o.isLogoutSubmitting){o.isLogoutSubmitting=!0,he(!0);try{o.token&&await x("/logout",{method:"POST"})}catch{}finally{ce(),window.location.assign("/admin")}}}async function bt(e){e==="dashboard"?await vt():e==="bookings"?await U():e==="customers"?await J():e==="analytics"?await re():e==="services"&&await ee()}async function vt(){w("#stat-total-bookings","70%"),w("#stat-pending","55%"),w("#stat-revenue","85%"),w("#stat-customers","60%"),le("#recent-orders-body",6,4),Ve("#top-customers-body",4);const e=await x("/admin/dashboard-batch",{timeoutMs:2e4,suppressToast:!0});let t={},s=[],n=[];if(e.ok)t=e.data?.stats??{},s=e.data?.recent_orders??[],n=e.data?.top_customers??[];else{const[h,k,v]=await Promise.all([x("/admin/stats",{timeoutMs:2e4,suppressToast:!0}),x("/admin/orders/recent",{timeoutMs:2e4,suppressToast:!0}),x("/admin/top-customers",{timeoutMs:2e4,suppressToast:!0})]);t=h.ok?h.data||{}:{},s=k.ok?k.data?.data||[]:[],n=v.ok?v.data?.data||[]:[]}const r=t.total_bookings??0,i=t.pending_count??0,l=t.revenue_today??0,p=t.customer_count??0;u("#stat-total-bookings",r),u("#stat-pending",i),u("#stat-revenue",C(l)),u("#stat-customers",p);const d=a("#stat-badge-total");d&&(d.className="stat-badge green",d.textContent="All time");const c=a("#stat-badge-pending");c&&(c.className=i>0?"stat-badge amber":"stat-badge green",c.textContent=i>0?"Needs action":"All clear");const m=a("#stat-badge-revenue");m&&(m.className=l>0?"stat-badge green":"stat-badge muted",m.textContent=l>0?"Live sales":"No orders yet today");const g=a("#stat-badge-customers");g&&(g.className="stat-badge green",g.textContent="Growing"),yt(s),ye(n,"#top-customers-body"),x("/admin/customers?page=1&per_page=20",{timeoutMs:2e4,suppressToast:!0}).catch(()=>{}),x("/admin/analytics",{timeoutMs:2e4,suppressToast:!0}).catch(()=>{})}function yt(e){const t=a("#recent-orders-body");if(t){if(t.innerHTML="",!e.length){t.innerHTML='<tr><td colspan="6">No recent orders.</td></tr>';return}e.forEach(s=>{const n=document.createElement("tr"),r=(s.status||"").toString().toLowerCase(),l=se(s.type||s.delivery_type)==="Pickup"?"🚚 Pickup":"Drop-off";n.innerHTML=`
      <td><span class="order-id">${s.id||""}</span></td>
      <td>${s.customer_name||"Unknown"}</td>
      <td>${s.service_type||"Service"}</td>
      <td>${l}</td>
      <td>${C(s.total_price||0)}</td>
      <td><span class="status-pill" data-status="${r}">${s.status||"Pending"}</span></td>
    `,t.appendChild(n)})}}const ze=[{bg:"#CFFAFE",color:"#0E7490"}],ht=["gold","silver","bronze","plain"];function ye(e,t){const s=typeof t=="string"?a(t):t;if(!s)return;if(s.innerHTML="",!e.length){s.innerHTML='<div style="font-size:13px;color:var(--color-text-secondary)">No data yet.</div>';return}const n=[],r=new Map;e.forEach(i=>{const l=(i?.name||"customer").toString().trim().toLowerCase(),p=i?.spend_raw??i?.total_spend??i?.spend??"",d=typeof p=="number"?p:Number(String(p).replace(/[^0-9.-]/g,""))||0,c=Number(i?.orders||0)||0;if(!r.has(l)){r.set(l,{name:i?.name||"Customer",orders:c,spend:d});return}const m=r.get(l);m.orders+=c,m.spend+=d}),r.forEach(i=>n.push(i)),n.sort((i,l)=>l.spend-i.spend),n.forEach((i,l)=>{const p=(i.name||"C").split(" ").map(h=>h[0]).join("").toUpperCase().slice(0,2),d=ze[l%ze.length],c=ht[Math.min(l,3)],m=`${l+1}`,g=document.createElement("div");g.className="top-customer-row",g.innerHTML=`
      <span class="medal-dot ${c}">${m}</span>
      <span class="customer-avatar" style="background:${d.bg};color:${d.color}">${p}</span>
      <div class="top-customer-info">
        <div class="top-customer-name">${i.name||"Customer"}</div>
        <div class="top-customer-meta">${i.orders||0} orders</div>
      </div>
      <div class="top-customer-spend">${C(i.spend||0)}</div>
    `,s.appendChild(g)})}function me(e){te("#booking-status-chips [data-status]").forEach(t=>{t.classList.toggle("active",t.dataset.status===e)})}async function kt(){const e=await x("/admin/booking-summaries");if(!e.ok)return;const t=e.data?.data||{},s=t.by_status||{},n=t.total??0;te("[data-status-count]").forEach(r=>{const i=r.dataset.statusCount,l=i==="all"?n:s[i]??0;u(r,l)})}function Ye(e,t){const s=ot(t);return t==="ready"||t==="completed"?(o.bookings.steps[e]=s,s):o.bookings.steps[e]!==void 0?o.bookings.steps[e]:s!==null?(o.bookings.steps[e]=s,s):null}function wt(e,t){return t===null?"":["Washing","Drying","Ready","Done"].map((n,r)=>`<button class="step-chip ${r===t?"active":""}" data-booking-step="${r}" data-order-id="${e}" type="button">${n}</button>`).join("")}function xt(e,t){const s=[];return t==="pending"&&(s.push(`<button class="button-outline btn-sm btn-success" data-booking-action="accept" data-order-id="${e}" type="button">Accept</button>`),s.push(`<button class="button-outline btn-sm btn-danger" data-booking-action="decline" data-order-id="${e}" type="button">Decline</button>`)),(t==="ongoing"||t==="ready")&&s.push(`<button class="button-outline btn-sm btn-success" data-booking-action="complete" data-order-id="${e}" type="button">Complete</button>`),s.join("")}function Je(e){const t=String(e),s=o.bookings.byId[t];if(!s)return;o.bookings.activeOrderId=t;const n=a("#booking-modal"),r=a("#booking-modal-overlay"),i=a("#booking-modal-body"),l=a("#booking-modal-title"),p=a("#booking-modal-subtitle"),d=ae(s),c=I(s.status)||"pending";l&&(l.textContent="Booking details"),p&&(p.textContent=`${d} · ${c}`),i&&(i.innerHTML=at(s)),r&&r.classList.add("show"),n&&(n.classList.add("show"),n.classList.remove("hidden"))}function Ke(){o.bookings.activeOrderId=null,a("#booking-modal-overlay")?.classList.remove("show");const e=a("#booking-modal");e&&(e.classList.remove("show"),e.classList.add("hidden"))}function Fe(e){const t=e.dataset.orderId,s=e.dataset.bookingAction;s==="accept"?(o.bookings.steps[t]=0,de(t,"ongoing")):s==="decline"?de(t,"cancelled"):s==="complete"&&(o.bookings.steps[t]=3,de(t,"completed"))}function He(e){const t=e.dataset.orderId,s=Number(e.dataset.bookingStep);Number.isNaN(s)||(o.bookings.steps[t]=s,de(t,nt(s)))}async function U(){le("#bookings-table-body",8,6),w("#bookings-footer-info","45%","sm");const e=kt(),t=a("#bookings-filter");t&&(t.value=o.bookings.status);const s=new URLSearchParams({page:o.bookings.page.toString(),per_page:o.bookings.perPage.toString()});o.bookings.status&&o.bookings.status!=="all"&&s.set("status",o.bookings.status),o.bookings.search&&s.set("search",o.bookings.search);const n=await x(`/admin/orders?${s.toString()}`),r=a("#bookings-table-body");if(!r)return;if(r.innerHTML="",!n.ok){r.innerHTML='<tr><td colspan="8">Unable to load bookings.</td></tr>';return}const i=n.data?.data||[],l=n.data?.pagination||{};if(o.bookings.byId={},!i.length){r.innerHTML='<tr><td colspan="8">No bookings found.</td></tr>',await e,me(o.bookings.status);return}i.forEach(g=>{const h=g.order_id||g.id,k=String(h);o.bookings.byId[k]=g;const v=I(g.status);Ye(h,v);const L=document.createElement("tr"),P=(g.customer_name||"Customer").split(" ").map(T=>T[0]).join("").substring(0,2).toUpperCase(),z=D(g.created_at),oe=ae(g),q=se(g.type||g.delivery_type)==="Pickup"?"🚚 Pickup":"Drop-off",M=[{bg:"#EEEDFE",color:"#3C3489"},{bg:"#E1F5EE",color:"#085041"},{bg:"#E6F1FB",color:"#0C447C"}],B=M[(g.customer_id||0)%M.length];L.innerHTML=`
      <td><span class="order-id">${oe}</span></td>
      <td>
        <div class="order-customer-cell">
          <span class="order-customer-avatar" style="background:${B.bg};color:${B.color}">${P}</span>
          <span class="order-customer-name">${g.customer_name||"Unknown"}</span>
        </div>
      </td>
      <td>${g.service_type||"Service"}</td>
      <td>${q}</td>
      <td>${C(g.total_price||0)}</td>
      <td>
        <span class="status-pill" data-status="${v}">
          <span class="status-dot"></span>
          ${v}
        </span>
      </td>
      <td><span class="order-created-date">${z}</span></td>
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
    `,r.appendChild(L)});const p=l.total||i.length;u("#bookings-footer-info",`Showing ${i.length} of ${p} orders — Page ${l.current_page||1} of ${l.last_page||1}`);const d=a("#bookings-prev"),c=a("#bookings-next"),m=a("#bookings-current-page");d&&(d.disabled=(l.current_page||1)<=1),c&&(c.disabled=(l.current_page||1)>=(l.last_page||1)),m&&(m.textContent=l.current_page||1),await e,me(o.bookings.status)}async function de(e,t){const s=String(e),n=await x(`/admin/orders/${e}/status`,{method:"PATCH",body:{status:t}});if(!n.ok){$("Unable to update status.");return}$("Order status updated.");const r=n.data?.data;await U(),r&&(o.bookings.byId[s]=r),o.bookings.activeOrderId===s&&Je(e)}async function J(){le("#customers-table-body",6,6),w("#customers-page-info","38%","sm");const e=new URLSearchParams({page:o.customers.page.toString(),per_page:o.customers.perPage.toString()});o.customers.search&&e.set("search",o.customers.search);const t=await x(`/admin/customers?${e.toString()}`,{timeoutMs:2e4}),s=a("#customers-table-body");if(!s)return;if(s.innerHTML="",!t.ok){s.innerHTML='<tr><td colspan="6">Unable to load customers.</td></tr>';return}const n=t.data?.data||[],r=t.data?.pagination||{};n.length||(s.innerHTML='<tr><td colspan="6">No customers found.</td></tr>'),n.forEach(p=>{const d=document.createElement("tr");d.innerHTML=`
      <td>
        <div class="font-semibold">${p.name||"Customer"}</div>
        <div class="text-xs text-slate-500">${p.email||""}</div>
      </td>
      <td>${p.phone||"---"}</td>
      <td>${p.orders_count||0}</td>
      <td>${C(p.total_spent||0)}</td>
      <td>${p.loyalty_points||0}</td>
      <td>
        <button class="button-outline" data-customer-id="${p.id}">View</button>
      </td>
    `,s.appendChild(d)}),u("#customers-page-info",`Page ${r.current_page||1} of ${r.last_page||1}`);const i=a("#customers-prev"),l=a("#customers-next");i&&(i.disabled=(r.current_page||1)<=1),l&&(l.disabled=(r.current_page||1)>=(r.last_page||1))}async function $t(e){o.currentCustomerId=e,a("#customer-drawer")?.classList.remove("hidden"),a("#customer-drawer")?.classList.add("show"),a("#customer-modal-overlay")?.classList.add("show"),u("#customer-drawer-title","Customer"),V(a("#customer-modal-loading")),K(a("#customer-modal-content")),E("customer-name"),E("customer-email"),E("customer-phone"),E("customer-zip");const t=await x(`/admin/customers/${e}`,{timeoutMs:2e4,suppressToast:!0});if(!t.ok){$(t.data?.message||"Unable to load customer details."),K(a("#customer-modal-loading"));return}const s=t.data?.data||{};u("#customer-drawer-title",s.name||"Customer"),a("#customer-name").value=s.name||"",a("#customer-email").value=s.email||"",a("#customer-phone").value=s.phone||"",a("#customer-address").value=s.address||"",a("#customer-city").value=s.city||"",a("#customer-zip").value=s.zip_code||"",a("#customer-country").value=s.country||"",a("#customer-notifications").checked=s.notifications_enabled!==!1,u("#customer-loyalty",s.loyalty_points||0),u("#customer-orders-count",s.orders_count||0),u("#customer-total-spent",C(s.total_spent||0)),u("#customer-dob",Y(D(s.date_of_birth))),u("#customer-gender",Y(s.gender)),u("#customer-language",Y(s.preferred_language)),u("#customer-email-verified",Me(!!s.email_verified_at)),u("#customer-profile-completed",Me(!!s.profile_completed_at)),u("#customer-member-since",Y(D(s.created_at))),u("#customer-last-login",Y(D(s.last_login_at))),u("#customer-bio",Y(s.bio)),o.customerOrders.page=1,o.customerOrders.lastPage=1,K(a("#customer-modal-loading")),V(a("#customer-modal-content")),Ze(!0)}function Re(){a("#customer-drawer")?.classList.remove("show"),a("#customer-drawer")?.classList.add("hidden"),a("#customer-modal-overlay")?.classList.remove("show"),o.currentCustomerId=null}function E(e,t=""){const s=a(`#${e}-error`);if(s){if(!t){s.textContent="",s.classList.add("hidden");return}s.textContent=t,s.classList.remove("hidden")}}function Ue(e,t){return String(e||"").replace(/\D+/g,"").slice(0,t)}function Lt(){const e=(a("#customer-name")?.value||"").trim(),t=(a("#customer-email")?.value||"").trim(),s=(a("#customer-phone")?.value||"").trim(),n=(a("#customer-zip")?.value||"").trim();let r=!0;return E("customer-name"),E("customer-email"),E("customer-phone"),E("customer-zip"),/^[A-Za-z.\s]+$/.test(e)||(E("customer-name","Name cannot contain numbers"),r=!1),t&&!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(t)&&(E("customer-email","Invalid email format"),r=!1),s&&!/^\d{1,11}$/.test(s)&&(E("customer-phone","Phone must contain only numbers (max 11 digits)"),r=!1),n&&!/^\d{1,4}$/.test(n)&&(E("customer-zip","ZIP must contain only numbers (max 4 digits)"),r=!1),r}async function _t(){if(!o.currentCustomerId||!Lt())return;const e=a("#customer-save");e&&(e.disabled=!0);const t={name:a("#customer-name").value.trim(),email:a("#customer-email").value.trim()||null,phone:a("#customer-phone").value.trim()||null,address:a("#customer-address").value.trim()||null,city:a("#customer-city").value.trim()||null,zip_code:a("#customer-zip").value.trim()||null,country:a("#customer-country").value.trim()||null,notifications_enabled:a("#customer-notifications").checked},s=await x(`/admin/customers/${o.currentCustomerId}`,{method:"PUT",body:t});if(!s.ok){const n=s.data?.message||s.data?.error||"Unable to update customer.";$(n),e&&(e.disabled=!1);return}$("Changes saved successfully"),await J(),e&&(e.disabled=!1)}async function Ze(e=!1){if(!o.currentCustomerId)return;e&&(o.customerOrders.page=1,le("#customer-orders-body",5,4),w("#customer-orders-page-info","40%","sm"),w("#customer-orders-title-count","28%","sm"));const t=new URLSearchParams({page:o.customerOrders.page.toString(),per_page:o.customerOrders.perPage.toString()}),s=await x(`/admin/customers/${o.currentCustomerId}/orders?${t.toString()}`),n=a("#customer-orders-body");if(!n)return;if(!s.ok){e&&(n.innerHTML='<tr><td colspan="5">Unable to load orders.</td></tr>');return}const r=s.data?.data||[],i=s.data?.pagination||{};e&&(n.innerHTML=""),!r.length&&e&&(n.innerHTML='<tr><td colspan="5">No orders yet.</td></tr>'),r.forEach(c=>{const m=document.createElement("tr"),g=se(c.type||c.delivery_type);m.innerHTML=`
      <td>${c.id||""}</td>
      <td>${c.service_type||""}</td>
      <td>${g}</td>
      <td>${C(c.total_price||0)}</td>
      <td>${c.status||""}</td>
    `,n.appendChild(m)}),o.customerOrders.lastPage=i.last_page||1;const l=i.current_page||o.customerOrders.page;u("#customer-orders-page-info",`Page ${l} of ${o.customerOrders.lastPage}`);const p=Number.isFinite(i.total)?i.total:r.length;u("#customer-orders-title-count",`(${p})`);const d=a("#customer-orders-load");if(d){const c=l>=o.customerOrders.lastPage;d.disabled=c,d.classList.toggle("hidden",c||p===0)}}async function re(){w("#analytics-month","38%","sm"),w("#analytics-monthly-revenue","70%"),w("#analytics-monthly-card","70%"),w("#analytics-completion-rate","35%"),w("#analytics-monthly-orders","38%"),w("#analytics-new-customers","45%"),w("#analytics-total-customers","55%","sm"),w("#analytics-completed-orders","40%"),w("#analytics-cancelled-orders","55%","sm"),w("#analytics-top-service","62%","sm"),w("#analytics-top-service-meta","44%","sm"),w("#analytics-top-customer","68%","sm"),w("#analytics-top-customer-meta","52%","sm"),w("#analytics-order-health","48%","sm");const e=a("#weekly-bars");e&&(e.innerHTML='<div style="width:100%;height:100%;" class="skeleton"></div>');const t=a("#service-breakdown-body");t&&(t.innerHTML=`${N("88%","sm")}<div style="margin-top:8px;">${N("70%","sm")}</div><div style="margin-top:8px;">${N("76%","sm")}</div>`);const s=a("#analytics-top-customers-list");s&&(s.innerHTML=`${N("86%","sm")}<div style="margin-top:8px;">${N("74%","sm")}</div><div style="margin-top:8px;">${N("68%","sm")}</div>`);const n=new URLSearchParams;o.analytics.startDate&&o.analytics.endDate?(n.set("start_date",o.analytics.startDate),n.set("end_date",o.analytics.endDate)):n.set("week_offset",String(o.analytics.weekOffset||0));const r=await x(`/admin/analytics?${n.toString()}`,{timeoutMs:2e4});if(!r.ok){$("Unable to load analytics.");return}const i=r.data||{},l=Number(i.monthly_revenue||0),p=Number(i.total_orders_this_month||0),d=Number(i.completed_orders_this_month||0),c=Number(i.cancelled_orders_this_month||0),m=Number(i.new_customers_this_month||0),g=Number(i.total_customers||0),h=Number(i.completion_rate||0),k=i.top_service||null,v=Array.isArray(i.top_customers)?i.top_customers:[],L=v[0]||null;u("#analytics-month",i.month_label||""),u("#analytics-monthly-revenue",C(l)),u("#analytics-monthly-card",C(l)),u("#analytics-completion-rate",`${h}%`),u("#analytics-monthly-orders",p),u("#analytics-new-customers",m),u("#analytics-total-customers",`${g} total customers`),u("#analytics-completed-orders",d),u("#analytics-cancelled-orders",`${c} cancelled`),u("#analytics-top-service",k?.name||"No service data yet"),u("#analytics-top-service-meta",k?`${k.orders||0} orders`:"No completed order mix yet"),u("#analytics-top-customer",L?.name||"No customer data yet"),u("#analytics-top-customer-meta",L?`${L.orders||0} orders · ${L.spend_label||C(L.spend||0)}`:"No customer orders yet"),u("#analytics-order-health",`${h}% completion`),u("#analytics-range-label",tt(i.chart_start||"",i.chart_end||"")||"Mon-Sun"),i.chart_mode==="custom"?(o.analytics.startDate=i.chart_start||o.analytics.startDate,o.analytics.endDate=i.chart_end||o.analytics.endDate):o.analytics.weekOffset=Number.isFinite(Number(i.week_offset))?Number(i.week_offset):o.analytics.weekOffset;const P=a("#analytics-start-date"),z=a("#analytics-end-date");P&&(P.value=o.analytics.startDate||""),z&&(z.value=o.analytics.endDate||"");const F=(Array.isArray(i.weekly_revenue)?i.weekly_revenue:[]).map((y,S)=>{if(y&&typeof y=="object"){const R=y.revenue??y.value??y.amount??0,A=Number(R||0);return{label:y.label||y.day||`Day ${S+1}`,value:Number.isFinite(A)?Math.max(0,A):0}}const _=Number(y||0);return{label:["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][S]||`Day ${S+1}`,value:Number.isFinite(_)?Math.max(0,_):0}}),q=Math.max(...F.map(y=>y.value),0),M=a("#weekly-bars");if(!M)return;M.innerHTML="",F.forEach(y=>{const S=Number(y.value||0),_=q>0?Math.max(0,S/q*100):0,R=S<=0,A=document.createElement("div");A.className="weekly-bar",A.innerHTML=`
      <div class="weekly-bar-value">${Pe(S)}</div>
      <div class="weekly-bar-track" title="${Pe(S)}">
        <div class="weekly-bar-fill ${R?"is-zero":""}" style="height:${_.toFixed(2)}%;"></div>
      </div>
      <div class="weekly-bar-label">${y.label||""}</div>
    `,M.appendChild(A)});const B=i.service_breakdown||[],T=a("#service-breakdown-body"),W=a("#service-breakdown-donut"),ne=a("#service-breakdown-total");T&&(T.innerHTML="");const ie=["#3B82F6","#34D399","#F59E0B","#EC4899","#A78BFA","#22D3EE"];let Z=0,G=0;const Q=[];if(!B.length)T&&(T.innerHTML='<div class="analytics-empty">No service data yet.</div>'),W&&(W.style.background="conic-gradient(rgba(148, 163, 184, 0.2) 0% 100%)"),ne&&u("#service-breakdown-total","0%");else if(B.forEach((y,S)=>{const _=Math.max(0,Math.min(100,Number(y.pct||0))),R=ie[S%ie.length];if(_>0&&Q.push(`${R} ${Z}% ${Z+_}%`),Z+=_,G+=_,T){const A=document.createElement("div");A.className="breakdown-legend-row",A.innerHTML=`
          <span class="breakdown-legend-swatch" style="background:${R};"></span>
          <div class="breakdown-legend-copy">
            <div class="breakdown-legend-name">${O(y.name||"Service")}</div>
            <div class="breakdown-legend-meta">${_}% &middot; ${y.count||0} orders</div>
          </div>
        `,T.appendChild(A)}}),W){const y=Math.min(100,Math.round(G));G<100&&Q.push(`rgba(148, 163, 184, 0.2) ${G}% 100%`),W.style.background=`conic-gradient(${Q.join(", ")})`,ne&&u("#service-breakdown-total",`${y}%`)}const H=a("#analytics-top-customers-list");H&&(H.innerHTML="",v.length?v.forEach((y,S)=>{const _=document.createElement("div");_.className="analytics-customer-row",_.innerHTML=`
          <span class="analytics-rank">${S+1}</span>
          <div class="analytics-customer-copy">
            <strong>${O(y.name||"Customer")}</strong>
            <span>${y.orders||0} orders</span>
          </div>
          <div class="analytics-customer-spend">${y.spend_label||C(y.spend||0)}</div>
        `,H.appendChild(_)}):H.innerHTML='<div class="analytics-empty">No customer spend data yet.</div>')}async function ee(){le("#services-table-body",5,5),Ve("#services-top-customers-body",4);const e=new URLSearchParams;o.services.search&&e.set("search",o.services.search);const t=e.toString()?`/admin/services?${e.toString()}`:"/admin/services",[s,n]=await Promise.all([x(t),x("/admin/top-customers")]),r=a("#services-table-body");if(!r)return;if(r.innerHTML="",!s.ok){r.innerHTML='<tr><td colspan="5">Unable to load services.</td></tr>',ye(n.ok?n.data?.data||[]:[],"#services-top-customers-body");return}const i=Array.isArray(s.data?.data)?s.data.data:Array.isArray(s.data)?s.data:[];o.services.items=i,i.length||(r.innerHTML='<tr><td colspan="5">No services found.</td></tr>'),i.forEach(l=>{const p=document.createElement("tr");p.innerHTML=`
      <td>
        <div class="font-semibold">${l.name||"Service"}</div>
        <div class="text-xs text-slate-500">${l.description||""}</div>
      </td>
      <td>${C(l.price_per_kg||0)}</td>
      <td>${l.category||"---"}</td>
      <td>${l.is_active?"Active":"Inactive"}</td>
      <td class="space-x-2">
        <button class="button-outline" data-edit-service="${l.id}">Edit</button>
        <button class="button-outline" data-delete-service="${l.id}">Delete</button>
      </td>
    `,r.appendChild(p)}),ye(n.ok?n.data?.data||[]:[],"#services-top-customers-body")}async function St(){const e={name:a("#service-name").value.trim(),description:a("#service-description").value.trim()||"",price_per_kg:Number(a("#service-price").value||0),category:a("#service-category").value||"",is_active:a("#service-active").checked},t=o.services.editingId;if(!(await x(`/admin/services${t?`/${t}`:""}`,{method:t?"PUT":"POST",body:e})).ok){$("Unable to save service.");return}$(t?"Service updated.":"Service created."),Qe(),await ee()}function Qe(){o.services.editingId=null,u("#service-form-title","Create service"),a("#service-name").value="",a("#service-description").value="",a("#service-price").value="",a("#service-category").value="",a("#service-active").checked=!0}async function Et(e){const t=Number(e);let s=o.services.items.find(n=>n.id===t);if(!s){const n=await x("/admin/services");if(!n.ok){$("Unable to load service details.");return}const r=Array.isArray(n.data?.data)?n.data.data:Array.isArray(n.data)?n.data:[];o.services.items=r,s=r.find(i=>i.id===t)}s&&(o.services.editingId=s.id,u("#service-form-title","Update service"),a("#service-name").value=s.name||"",a("#service-description").value=s.description||"",a("#service-price").value=s.price_per_kg||"",a("#service-category").value=s.category||"",a("#service-active").checked=s.is_active!==!1)}async function Ct(e){if(!window.confirm("Are you sure you want to delete this service?"))return;if(!(await x(`/admin/services/${e}`,{method:"DELETE"})).ok){$("Unable to delete service.");return}$("Service deleted."),await ee()}function Be(e,t,s){e.type=s?"text":"password",t.setAttribute("aria-pressed",s?"true":"false"),t.setAttribute("aria-label",s?"Hide password":"Show password"),t.innerHTML=s?'<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>':'<svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>'}function Dt(){const e=a("#login-form");e&&e.addEventListener("submit",pt);const t=a("#toggle-password"),s=a("#login-password");t&&s&&(Be(s,t,!1),t.addEventListener("click",()=>{const f=s.type==="password";Be(s,t,f)}));const n=a("#logout-button");n&&n.addEventListener("click",mt);const r=a("#logout-modal-cancel");r&&r.addEventListener("click",Ie);const i=a("#logout-modal-confirm");i&&i.addEventListener("click",ft);const l=a("#logout-modal-overlay");l&&l.addEventListener("click",Ie),te("[data-view]").forEach(f=>{f.addEventListener("click",()=>{pe(f.dataset.view,{syncUrl:!0}),Ne()})});const p=a("#analytics-prev-week");p&&p.addEventListener("click",()=>{o.analytics.startDate="",o.analytics.endDate="",o.analytics.weekOffset-=1,re()});const d=a("#analytics-next-week");d&&d.addEventListener("click",()=>{o.analytics.startDate="",o.analytics.endDate="",o.analytics.weekOffset+=1,re()});const c=a("#analytics-apply-range");c&&c.addEventListener("click",()=>{const f=(a("#analytics-start-date")?.value||"").trim(),b=(a("#analytics-end-date")?.value||"").trim();if(!f||!b){$("Please select both start and end dates.");return}if(f>b){$("Start date must be before or equal to end date.");return}o.analytics.startDate=f,o.analytics.endDate=b,o.analytics.weekOffset=0,re()});const m=a("#analytics-reset-range");m&&m.addEventListener("click",()=>{o.analytics.startDate="",o.analytics.endDate="",o.analytics.weekOffset=0;const f=a("#analytics-start-date"),b=a("#analytics-end-date");f&&(f.value=""),b&&(b.value=""),re()});const g=a("#bookings-filter");g&&g.addEventListener("change",f=>{o.bookings.status=f.target.value,o.bookings.page=1,me(o.bookings.status),U()});const h=a("#booking-status-chips");h&&h.addEventListener("click",f=>{const b=f.target.closest("[data-status]");b&&(o.bookings.status=b.dataset.status,o.bookings.page=1,me(o.bookings.status),g&&(g.value=o.bookings.status),U())});const k=a("#bookings-prev");k&&k.addEventListener("click",()=>{o.bookings.page=Math.max(1,o.bookings.page-1),U()});const v=a("#bookings-next");v&&v.addEventListener("click",()=>{o.bookings.page+=1,U()});const L=a("#bookings-table-body");L&&(L.addEventListener("change",f=>{const b=f.target.closest("select[data-order-id]");b&&de(b.dataset.orderId,b.value)}),L.addEventListener("click",f=>{const b=f.target.closest("[data-cod-receipt-id]");if(b){const ge=b.dataset.codReceiptId,Ae=o.bookings.byId[String(ge)];Ae?Tt(Ae):$("Receipt data unavailable. Please refresh.");return}const j=f.target.closest("[data-booking-toggle]");if(j){const ge=j.dataset.bookingToggle;Je(ge);return}const De=f.target.closest("[data-booking-action]");if(De){Fe(De);return}const Te=f.target.closest("[data-booking-step]");Te&&He(Te)}));const P=a("#booking-modal-close");P&&P.addEventListener("click",Ke);const z=a("#booking-modal");z&&z.addEventListener("click",f=>{const b=f.target.closest("[data-booking-action]");if(b){Fe(b);return}const j=f.target.closest("[data-booking-step]");j&&He(j)});const oe=a("#customers-search-button");oe&&oe.addEventListener("click",()=>{o.customers.search=a("#customers-search-input").value.trim(),o.customers.page=1,J()});const F=a("#customers-search-input");if(F){let f=null;F.addEventListener("input",()=>{f&&clearTimeout(f),f=setTimeout(()=>{o.customers.search=F.value.trim(),o.customers.page=1,J()},300)}),F.addEventListener("keydown",b=>{b.key==="Enter"&&(b.preventDefault(),o.customers.search=F.value.trim(),o.customers.page=1,J())})}const q=a("#bookings-search-button");q&&q.addEventListener("click",()=>{o.bookings.search=(a("#bookings-search-input")?.value||"").trim(),o.bookings.page=1,U()});const M=a("#bookings-search-input");if(M){let f=null;M.addEventListener("input",()=>{f&&clearTimeout(f),f=setTimeout(()=>{o.bookings.search=M.value.trim(),o.bookings.page=1,U()},300)}),M.addEventListener("keydown",b=>{b.key==="Enter"&&(b.preventDefault(),o.bookings.search=M.value.trim(),o.bookings.page=1,U())})}const B=a("#services-search-button");B&&B.addEventListener("click",()=>{o.services.search=(a("#services-search-input")?.value||"").trim(),ee()});const T=a("#services-search-input");if(T){let f=null;T.addEventListener("input",()=>{f&&clearTimeout(f),f=setTimeout(()=>{o.services.search=T.value.trim(),ee()},300)}),T.addEventListener("keydown",b=>{b.key==="Enter"&&(b.preventDefault(),o.services.search=T.value.trim(),ee())})}const W=a("#customers-prev");W&&W.addEventListener("click",()=>{o.customers.page=Math.max(1,o.customers.page-1),J()});const ne=a("#customers-next");ne&&ne.addEventListener("click",()=>{o.customers.page+=1,J()});const ie=a("#customers-table-body");ie&&ie.addEventListener("click",f=>{const b=f.target.closest("[data-customer-id]");b&&$t(b.dataset.customerId)});const Z=a("#customer-drawer-close");Z&&Z.addEventListener("click",Re);const G=a("#customer-modal-overlay");G&&G.addEventListener("click",Re);const Q=a("#customer-save");Q&&Q.addEventListener("click",_t);const H=a("#customer-name");H&&H.addEventListener("input",()=>{E("customer-name"),H.value=H.value.replace(/[^A-Za-z.\s]/g,"")});const y=a("#customer-email");y&&y.addEventListener("input",()=>{E("customer-email")});const S=a("#customer-phone");S&&S.addEventListener("input",()=>{E("customer-phone"),S.value=Ue(S.value,11)});const _=a("#customer-zip");_&&_.addEventListener("input",()=>{E("customer-zip"),_.value=Ue(_.value,4)});const R=a("#customer-orders-load");R&&R.addEventListener("click",()=>{o.customerOrders.page>=o.customerOrders.lastPage||(o.customerOrders.page+=1,Ze())});const A=a("#service-save");A&&A.addEventListener("click",St);const ke=a("#service-clear");ke&&ke.addEventListener("click",Qe);const we=a("#services-table-body");we&&we.addEventListener("click",f=>{const b=f.target.closest("[data-edit-service]");if(b){Et(b.dataset.editService);return}const j=f.target.closest("[data-delete-service]");j&&Ct(j.dataset.deleteService)});const xe=a("#recent-orders-view-all");xe&&xe.addEventListener("click",()=>pe("bookings",{syncUrl:!0}));const $e=a("#sidebar-toggle");$e&&$e.addEventListener("click",lt);const Le=a("#sidebar-overlay");Le&&Le.addEventListener("click",Ne);const _e=a("#cod-receipt-close");_e&&_e.addEventListener("click",be);const Se=a("#cod-receipt-cancel");Se&&Se.addEventListener("click",be);const Ee=a("#cod-receipt-print");Ee&&Ee.addEventListener("click",At);const Ce=a("#cod-receipt-overlay");Ce&&Ce.addEventListener("click",be)}window.addEventListener("DOMContentLoaded",()=>{Dt(),window.addEventListener("popstate",()=>{if(!o.token)return;const e=qe(window.location.pathname);pe(e,{replaceUrl:!0,syncUrl:!1})}),ut()});function Tt(e){const t=a("#cod-receipt-modal"),s=a("#cod-receipt-overlay"),n=a("#cod-receipt-body");if(!t||!s||!n)return;const r=ae(e),i=se(e.delivery_type),l=D(e.pickup_date),p=D(e.delivery_date),d=D(e.created_at),c=C(e.total_price||0),m=new Date().toLocaleDateString("en-PH",{month:"short",day:"numeric",year:"numeric"}),g=(h,k,v="")=>`
    <tr>
      <td style="padding:9px 12px; color:#58708D; font-size:12px; font-weight:500; width:42%; white-space:nowrap; vertical-align:middle;">
        ${v?`<span style="margin-right:5px; opacity:0.7;">${v}</span>`:""}${h}
      </td>
      <td style="padding:9px 12px; color:#08213D; font-size:12.5px; font-weight:600; vertical-align:middle;">${k}</td>
    </tr>`;n.innerHTML=`
    <div id="cod-receipt-print-area" style="font-family:'Segoe UI',Arial,sans-serif; color:#08213D; background:#fff;">

      <!-- Branded Header -->
      <div style="background:linear-gradient(135deg,#1565C0 0%,#0D47A1 100%); padding:22px 24px 20px; text-align:center; position:relative; overflow:hidden;">
        <div style="position:absolute;top:-18px;right:-18px;width:90px;height:90px;border-radius:50%;background:rgba(255,255,255,0.07);"></div>
        <div style="position:absolute;bottom:-24px;left:-12px;width:70px;height:70px;border-radius:50%;background:rgba(255,255,255,0.05);"></div>
        <div style="font-size:10px; font-weight:800; letter-spacing:0.22em; text-transform:uppercase; color:rgba(255,255,255,0.65); margin-bottom:6px;">LaundryHub</div>
        <div style="font-size:24px; font-weight:800; color:#fff; letter-spacing:-0.5px; margin-bottom:4px;">Cash on Delivery Receipt</div>
        <div style="display:inline-block; background:rgba(255,255,255,0.15); border-radius:20px; padding:3px 14px; font-size:12px; font-weight:700; color:#fff; letter-spacing:0.05em;">${r}</div>
        <div style="margin-top:6px; font-size:11px; color:rgba(255,255,255,0.55);">Issued: ${m}</div>
      </div>

      <!-- Detail Rows -->
      <div style="padding:4px 0;">
        <table style="width:100%; border-collapse:collapse;">
          <tbody>
            <tr style="background:#F8FBFF;">
              <td colspan="2" style="padding:7px 12px; font-size:10px; font-weight:800; letter-spacing:0.12em; text-transform:uppercase; color:#58708D;">Customer Info</td>
            </tr>
            ${g("Customer",O(e.customer_name||"N/A"),"👤")}
            ${g("Address",O(e.pickup_address||"N/A"),"📍")}
            <tr style="background:#F8FBFF;">
              <td colspan="2" style="padding:7px 12px; font-size:10px; font-weight:800; letter-spacing:0.12em; text-transform:uppercase; color:#58708D;">Order Details</td>
            </tr>
            ${g("Service",O(e.service_type||"---"),"🧺")}
            ${g("Weight",`${e.weight_kg||0} kg`,"⚖️")}
            ${g("Fulfillment",i,"🚚")}
            ${g("Pickup Date",l,"📅")}
            ${g("Delivery Date",p,"📅")}
            ${g("Order Date",d,"🗓️")}
          </tbody>
        </table>
      </div>

      <!-- Total Banner -->
      <div style="margin:0 16px 16px; background:linear-gradient(135deg,#EEF4FF 0%,#E8F0FE 100%); border:1px solid rgba(21,101,192,0.18); border-radius:10px; padding:16px 20px; display:flex; align-items:center; justify-content:space-between;">
        <div>
          <div style="font-size:10px; font-weight:700; letter-spacing:0.10em; text-transform:uppercase; color:#58708D; margin-bottom:2px;">Total Amount Due</div>
          <div style="font-size:26px; font-weight:800; color:#1565C0; letter-spacing:-0.5px;">${c}</div>
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
  `,t.classList.remove("hidden"),t.classList.add("show"),s.classList.add("show")}function be(){const e=a("#cod-receipt-modal"),t=a("#cod-receipt-overlay");e&&(e.classList.remove("show"),e.classList.add("hidden")),t&&t.classList.remove("show")}function At(){const e=a("#cod-receipt-modal");if(!e||e.classList.contains("hidden")){$("Open a receipt first.");return}const t=Array.from(e.querySelectorAll("#cod-receipt-print-area table tbody tr")).filter(v=>!v.querySelector("[colspan]")).map(v=>{const L=v.querySelectorAll("td");if(L.length<2)return null;const P=L[0].textContent.replace(/[\u{1F000}-\u{1FFFF}]/gu,"").trim(),z=L[1].textContent.trim();return{label:P,value:z}}).filter(Boolean);e.querySelector(".btn-action-receipt")?.dataset?.codReceiptId;const s=e.querySelector("#cod-receipt-print-area > div:first-child"),n=s?s.querySelectorAll("div"):[],r=n[2]?.textContent?.trim()||"",i=n[3]?.textContent?.trim()||"",p=e.querySelector('#cod-receipt-print-area [style*="font-size:26px"]')?.textContent?.trim()||"";t.map(({label:v,value:L})=>`
    <tr>
      <td class="label-col">${v}</td>
      <td class="value-col">${L}</td>
    </tr>`).join("");const d=["Customer","Address"],c=t.filter(v=>d.includes(v.label)),m=t.filter(v=>!d.includes(v.label)),g=v=>v.map(({label:L,value:P})=>`
    <tr>
      <td class="label">${L}</td>
      <td class="value">${P}</td>
    </tr>`).join(""),h=`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>COD Receipt ${r}</title>
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
      <div class="order-pill">${r}</div>
      <div class="issued">${i}</div>
    </div>

    <div class="section">
      <div class="section-head">Customer Information</div>
      <table>
        ${g(c)}
      </table>

      <div class="section-head">Order Details</div>
      <table>
        ${g(m)}
      </table>
    </div>

    <div class="total-box">
      <div>
        <div class="total-label">Total Amount Paid</div>
        <div class="total-amount">${p}</div>
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
</html>`,k=window.open("","_blank","width=680,height=860");if(!k){$("Allow pop-ups to print/save this receipt.");return}k.document.open(),k.document.write(h),k.document.close(),k.onload=()=>{k.focus(),k.print()}}function Mt(){const e=document.getElementById("report-filter")?.value||"all";let t=Object.values(o.bookings.byId||{});if(e!=="all"&&(t=t.filter(c=>I(c.status)===e)),!t.length){$("No orders available to export.");return}const s=["Order ID","Customer Name","Service Type","Delivery Type","Weight (kg)","Total Price","Status","Pickup Date","Delivery Date","Pickup Address","Created At"],n=c=>{const m=String(c??"").trim();return m.includes(",")||m.includes('"')||m.includes(`
`)?`"${m.replace(/"/g,'""')}"`:m},r=t.map(c=>[n(ae(c)),n(c.customer_name||"N/A"),n(c.service_type||"N/A"),n(se(c.delivery_type)),c.weight_kg||0,c.total_price||0,n(I(c.status)),n(D(c.pickup_date)),n(D(c.delivery_date)),n(c.pickup_address||"N/A"),n(D(c.created_at))]),i=[s.join(","),...r.map(c=>c.join(","))].join(`
`),l=new Blob([i],{type:"text/csv;charset=utf-8;"}),p=URL.createObjectURL(l),d=document.createElement("a");d.href=p,d.setAttribute("download",`LaundryHub_Master_Report_${e}_${new Date().toISOString().split("T")[0]}.csv`),document.body.appendChild(d),d.click(),document.body.removeChild(d)}function Pt(){const e=document.getElementById("report-filter")?.value||"all";let t=Object.values(o.bookings.byId||{});if(e!=="all"&&(t=t.filter(d=>I(d.status)===e)),!t.length){$("No data to export.");return}const s=t.reduce((d,c)=>d+Number(c.total_price||0),0),n=t.reduce((d,c)=>d+Number(c.weight_kg||0),0),r={};t.forEach(d=>{const c=d.service_type||"General";r[c]=(r[c]||0)+1});const i=window.open("","_blank","width=1000,height=1200");if(!i)return;const l=t.map(d=>`
    <tr>
      <td style="font-family:monospace; font-size:11px;">${ae(d)}</td>
      <td style="font-weight:600;">${O(d.customer_name||"N/A")}</td>
      <td>${O(d.service_type||"N/A")}</td>
      <td>${d.weight_kg||0}kg</td>
      <td style="font-weight:700; color:#1e40af;">${C(d.total_price||0)}</td>
      <td><span class="status-badge ${I(d.status)}">${I(d.status)}</span></td>
      <td style="color:#64748b; font-size:11px;">${D(d.created_at)}</td>
    </tr>
  `).join(""),p=Object.entries(r).sort((d,c)=>c[1]-d[1]).map(([d,c])=>`
      <div class="service-stat">
        <span class="service-name">${d}</span>
        <span class="service-count">${c} orders</span>
      </div>
    `).join("");i.document.write(`
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
            <p>Scope: ${e.toUpperCase()}</p>
            <p>Ref: LH-REP-${new Date().getTime().toString().slice(-6)}</p>
            <p>${new Date().toLocaleDateString("en-PH",{month:"long",day:"numeric",year:"numeric"})}</p>
          </div>
        </div>

        <div class="grid-summary">
          <div class="stats-panel">
            <div class="stat-item">
              <div class="stat-label">Total Transactions</div>
              <div class="stat-value">${t.length}</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">Processed Weight</div>
              <div class="stat-value">${n.toFixed(1)}kg</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">Gross Revenue</div>
              <div class="stat-value">${C(s)}</div>
            </div>
          </div>
          <div class="breakdown-panel">
            <div class="breakdown-title">Service Performance</div>
            ${p}
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
            ${l}
          </tbody>
        </table>

        <div class="signature-section">
          <div class="sig-box">
            <div class="sig-label">Prepared By</div>
            <div class="sig-date">${o.user?.name||"Admin"}</div>
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
  `),i.document.close(),i.onload=()=>{i.focus(),i.print()}}document.addEventListener("DOMContentLoaded",()=>{const e=document.getElementById("btn-download-csv"),t=document.getElementById("btn-download-pdf");e&&e.addEventListener("click",Mt),t&&t.addEventListener("click",Pt)});
