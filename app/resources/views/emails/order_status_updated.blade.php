<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Order Status Updated</title>
</head>
<body style="margin:0;padding:0;background:#f4f7fb;font-family:Arial,sans-serif;color:#1f2937;">
    <div style="max-width:640px;margin:24px auto;background:#ffffff;border:1px solid #e5e7eb;border-radius:10px;overflow:hidden;">
        <div style="background:#2563eb;color:#ffffff;padding:16px 20px;font-size:20px;font-weight:700;">LaundryHub</div>
        <div style="padding:20px;line-height:1.6;">
            <h2 style="margin:0 0 12px;">Order Status Updated</h2>
            <p style="margin:0 0 12px;">Hello {{ $customerName }}, your order status changed.</p>
            <p style="margin:0 0 16px;"><strong>Order ID:</strong> {{ $displayOrderId }}</p>

            <table style="width:100%;border-collapse:collapse;">
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Service</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $serviceName }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>From</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $fromStatus }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>To</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $toStatus }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Fulfillment</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $deliveryTypeLabel }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Total</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">PHP {{ number_format($totalPrice, 2) }}</td></tr>
            </table>

            <div style="margin:20px 0;text-align:center;">
                <a href="{{ url('/') }}/orders/{{ $orderId }}" style="display:inline-block;background:#2563eb;color:#fff;padding:12px 24px;border-radius:6px;text-decoration:none;font-weight:bold;">View Full Details</a>
            </div>
        </div>
        
        <div style="border-top:1px solid #e5e7eb;padding:20px;background:#f9fafb;font-size:13px;color:#6b7280;">
            <p style="margin:0 0 8px;"><strong>Need Help?</strong></p>
            <p style="margin:0 0 12px;">Check your LaundryHub app for real-time order tracking and updates.</p>
            <p style="margin:8px 0;">
                <a href="{{ url('/') }}/notifications-settings" style="color:#2563eb;text-decoration:none;">Manage Notifications</a> | 
                <a href="{{ url('/') }}/profile" style="color:#2563eb;text-decoration:none;">Account Settings</a>
            </p>
            <hr style="border:none;border-top:1px solid #e5e7eb;margin:12px 0;">
            <p style="margin:8px 0;text-align:center;">© 2026 LaundryHub. All rights reserved.</p>
            <p style="margin:4px 0;text-align:center;">
                <a href="{{ url('/') }}/unsubscribe?email={{ $customerEmail ?? '' }}" style="color:#9ca3af;text-decoration:none;font-size:12px;">Unsubscribe from emails</a>
            </p>
        </div>
    </div>
</body>
</html>
