<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Delivery Scheduled</title>
</head>
<body style="margin:0;padding:0;background:#f4f7fb;font-family:Arial,sans-serif;color:#1f2937;">
    <div style="max-width:640px;margin:24px auto;background:#ffffff;border:1px solid #e5e7eb;border-radius:10px;overflow:hidden;">
        <div style="background:#0ea5e9;color:#ffffff;padding:16px 20px;font-size:20px;font-weight:700;">LaundryHub - Delivery Confirmed</div>
        <div style="padding:20px;line-height:1.6;">
            <h2 style="margin:0 0 12px;">Your Delivery Is Scheduled</h2>
            <p style="margin:0 0 12px;">Hello {{ $customerName }}, your laundry order has been scheduled for delivery.</p>
            <p style="margin:0 0 16px;"><strong>Order ID:</strong> {{ $displayOrderId }}</p>

            <table style="width:100%;border-collapse:collapse;">
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Service</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $serviceName }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Delivery Amount</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">PHP {{ number_format($totalPrice, 2) }}</td></tr>
                @if($deliveryDate)
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Delivery Date</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $deliveryDate }}</td></tr>
                @endif
                @if($deliveryTime)
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Delivery Time Window</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $deliveryTime }}</td></tr>
                @endif
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Delivery Address</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $deliveryAddress }}</td></tr>
            </table>

            <div style="margin:20px 0;padding:12px;background:#dbeafe;border-radius:6px;border-left:4px solid #0ea5e9;color:#0369a1;">
                <p style="margin:0;font-weight:bold;">Delivery confirmed</p>
                <p style="margin:4px 0 0;font-size:13px;">Our team will deliver your items on the scheduled date. Please ensure someone is available to receive the order.</p>
            </div>

            <div style="margin:20px 0;text-align:center;">
                <a href="{{ url('/') }}/orders/{{ $orderId }}" style="display:inline-block;background:#0ea5e9;color:#fff;padding:12px 24px;border-radius:6px;text-decoration:none;font-weight:bold;">View Delivery Details</a>
            </div>

            <p style="margin:16px 0;font-size:13px;color:#6b7280;">You will receive a reminder notification before the delivery date.</p>
        </div>

        <div style="border-top:1px solid #e5e7eb;padding:20px;background:#f9fafb;font-size:13px;color:#6b7280;">
            <p style="margin:0 0 8px;"><strong>Important</strong></p>
            <p style="margin:0 0 12px;">If you need to reschedule your delivery or have special instructions, please update through the LaundryHub app as soon as possible.</p>
            <p style="margin:8px 0;">
                <a href="{{ url('/') }}/notifications-settings" style="color:#2563eb;text-decoration:none;">Manage Notifications</a> |
                <a href="{{ url('/') }}/profile" style="color:#2563eb;text-decoration:none;">Account Settings</a>
            </p>
            <hr style="border:none;border-top:1px solid #e5e7eb;margin:12px 0;">
            <p style="margin:8px 0;text-align:center;">(c) 2026 LaundryHub. All rights reserved.</p>
            <p style="margin:4px 0;text-align:center;">
                <a href="{{ url('/') }}/unsubscribe?email={{ $customerEmail ?? '' }}" style="color:#9ca3af;text-decoration:none;font-size:12px;">Unsubscribe from emails</a>
            </p>
        </div>
    </div>
</body>
</html>
