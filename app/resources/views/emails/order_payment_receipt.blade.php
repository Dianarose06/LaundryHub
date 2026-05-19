<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Payment Receipt — LaundryHub</title>
</head>
<body style="margin:0;padding:0;background:#EEF3FA;font-family:'Segoe UI',Arial,sans-serif;color:#08213D;">

  <div style="max-width:600px;margin:28px auto;background:#ffffff;border-radius:14px;overflow:hidden;box-shadow:0 4px 24px rgba(15,23,42,0.09);">

    <!-- ── Header ── -->
    <div style="background:linear-gradient(135deg,#1565C0 0%,#0D47A1 100%);padding:32px 32px 28px;text-align:center;position:relative;overflow:hidden;">
      <div style="position:absolute;top:-30px;right:-30px;width:120px;height:120px;border-radius:50%;background:rgba(255,255,255,0.06);"></div>
      <div style="position:absolute;bottom:-40px;left:-20px;width:100px;height:100px;border-radius:50%;background:rgba(255,255,255,0.04);"></div>
      <div style="font-size:10px;font-weight:800;letter-spacing:0.25em;text-transform:uppercase;color:rgba(255,255,255,0.6);margin-bottom:10px;">LaundryHub</div>
      <div style="display:inline-flex;align-items:center;justify-content:center;width:52px;height:52px;border-radius:50%;background:rgba(255,255,255,0.15);margin-bottom:14px;">
        <span style="font-size:24px;">🧾</span>
      </div>
      <div style="font-size:26px;font-weight:800;color:#ffffff;letter-spacing:-0.5px;margin-bottom:8px;">Payment Receipt</div>
      <div style="display:inline-block;background:rgba(255,255,255,0.15);border-radius:20px;padding:4px 18px;font-size:13px;font-weight:700;color:#fff;letter-spacing:0.06em;">{{ $displayOrderId }}</div>
    </div>

    <!-- ── Greeting ── -->
    <div style="padding:24px 28px 0;">
      <p style="margin:0 0 4px;font-size:16px;font-weight:700;color:#08213D;">Hello, {{ $customerName }} 👋</p>
      <p style="margin:0;font-size:13.5px;color:#58708D;line-height:1.6;">Your laundry order has been completed and your COD payment has been received. Here's your official receipt.</p>
    </div>

    <!-- ── Payment Confirmed Banner ── -->
    <div style="margin:20px 28px 0;background:linear-gradient(135deg,#E8F5E9,#F1F8E9);border:1px solid rgba(46,125,50,0.20);border-radius:10px;padding:14px 18px;display:flex;align-items:center;gap:14px;">
      <div style="width:40px;height:40px;border-radius:50%;background:#2E7D32;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:20px;color:#fff;font-weight:900;">✓</div>
      <div>
        <div style="font-size:14px;font-weight:700;color:#1B5E20;margin-bottom:2px;">Payment Confirmed</div>
        <div style="font-size:12px;color:#388E3C;line-height:1.4;">Cash on Delivery payment received for this order.</div>
      </div>
    </div>

    <!-- ── Order Details ── -->
    <div style="margin:20px 28px 0;">
      <div style="font-size:10px;font-weight:800;letter-spacing:0.14em;text-transform:uppercase;color:#58708D;margin-bottom:10px;">Order Details</div>
      <table style="width:100%;border-collapse:collapse;border-radius:10px;overflow:hidden;border:1px solid rgba(21,101,192,0.12);">
        <tbody>
          @php
            $rows = [
              ['🧺', 'Service',          $serviceName],
              ['⚖️', 'Weight',           number_format($weightKg, 2) . ' kg'],
              ['🚚', 'Fulfillment',      $deliveryTypeLabel],
              ['📅', 'Pickup Date',      $pickupDate ?? 'N/A'],
              ['📅', 'Delivery Date',    $deliveryDate ?? 'N/A'],
              ['🗓️', 'Transaction Date', $completionDate],
              ['💳', 'Payment Method',   'Cash on Delivery (COD)'],
            ];
          @endphp
          @foreach ($rows as $i => $r)
          <tr style="{{ $i % 2 === 0 ? 'background:#F8FBFF;' : 'background:#fff;' }}">
            <td style="padding:11px 16px;width:46%;font-size:12.5px;font-weight:500;color:#58708D;white-space:nowrap;">
              <span style="margin-right:6px;opacity:0.75;">{{ $r[0] }}</span>{{ $r[1] }}
            </td>
            <td style="padding:11px 16px;font-size:13px;font-weight:600;color:#08213D;">{{ $r[2] }}</td>
          </tr>
          @endforeach
        </tbody>
      </table>
    </div>

    <!-- ── Total Amount ── -->
    <div style="margin:16px 28px 0;background:linear-gradient(135deg,#EEF4FF,#E8F0FE);border:1px solid rgba(21,101,192,0.18);border-radius:10px;padding:18px 22px;display:flex;align-items:center;justify-content:space-between;">
      <div>
        <div style="font-size:10px;font-weight:700;letter-spacing:0.12em;text-transform:uppercase;color:#58708D;margin-bottom:4px;">Total Amount Paid</div>
        <div style="font-size:30px;font-weight:800;color:#1565C0;letter-spacing:-1px;">PHP {{ number_format($totalPrice, 2) }}</div>
      </div>
      <div style="width:52px;height:52px;border-radius:50%;background:rgba(21,101,192,0.10);display:flex;align-items:center;justify-content:center;font-size:24px;">💳</div>
    </div>

    <!-- ── CTA ── -->
    <div style="margin:24px 28px 0;text-align:center;">
      <a href="{{ url('/') }}/orders/{{ $orderId }}" style="display:inline-block;background:linear-gradient(135deg,#1565C0,#0D47A1);color:#fff;padding:13px 32px;border-radius:10px;text-decoration:none;font-size:14px;font-weight:700;letter-spacing:0.02em;box-shadow:0 4px 14px rgba(21,101,192,0.28);">View Receipt &amp; Track Order →</a>
    </div>

    <!-- ── Note ── -->
    <div style="margin:20px 28px 0;padding:14px 16px;background:#FFFBEB;border:1px solid rgba(202,138,4,0.22);border-radius:8px;">
      <p style="margin:0;font-size:12px;color:#92400E;line-height:1.6;">
        📌 <strong>Keep this receipt</strong> for your records. A copy has been saved to your LaundryHub account. If you have any concerns, please contact our support team.
      </p>
    </div>

    <!-- ── Footer ── -->
    <div style="margin-top:28px;padding:20px 28px;background:#F8FBFF;border-top:1px solid rgba(21,101,192,0.10);">
      <div style="display:flex;justify-content:center;gap:24px;margin-bottom:14px;">
        <a href="{{ url('/') }}/my-orders" style="font-size:12px;color:#1565C0;text-decoration:none;font-weight:600;">My Orders</a>
        <a href="{{ url('/') }}/notifications-settings" style="font-size:12px;color:#1565C0;text-decoration:none;font-weight:600;">Notification Settings</a>
        <a href="{{ url('/') }}/unsubscribe?email={{ $customerEmail ?? '' }}" style="font-size:12px;color:#9CA3AF;text-decoration:none;">Unsubscribe</a>
      </div>
      <p style="margin:0;text-align:center;font-size:11px;color:#9CA3AF;">© 2026 LaundryHub. All rights reserved.</p>
      <p style="margin:4px 0 0;text-align:center;font-size:11px;color:#C4CDD8;">This is an automated receipt. Please do not reply to this email.</p>
    </div>

  </div>

</body>
</html>
