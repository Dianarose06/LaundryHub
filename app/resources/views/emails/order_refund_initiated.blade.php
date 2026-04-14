<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Order Cancelled & Refund Initiated</title>
</head>
<body style="margin:0;padding:0;background:#f4f7fb;font-family:Arial,sans-serif;color:#1f2937;">
    <div style="max-width:640px;margin:24px auto;background:#ffffff;border:1px solid #e5e7eb;border-radius:10px;overflow:hidden;">
        <div style="background:#ef4444;color:#ffffff;padding:16px 20px;font-size:20px;font-weight:700;">LaundryHub - Refund Initiated</div>
        <div style="padding:20px;line-height:1.6;">
            <h2 style="margin:0 0 12px;">Order Cancelled & Refund Initiated</h2>
            <p style="margin:0 0 12px;">Hello {{ $customerName }}, your order has been cancelled and your refund has been initiated.</p>
            <p style="margin:0 0 16px;"><strong>Order ID:</strong> {{ $displayOrderId }}</p>

            <div style="margin:16px 0;padding:12px;background:#fee2e2;border-radius:6px;border-left:4px solid #ef4444;color:#7f1d1d;">
                <p style="margin:0;font-weight:bold;">Refund processing</p>
                <p style="margin:4px 0 0;font-size:13px;">Your refund is being processed and will be returned to your original payment method within 3-5 business days.</p>
            </div>

            <table style="width:100%;border-collapse:collapse;margin:16px 0;">
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Service</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $serviceName }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Refund Amount</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">PHP {{ number_format($refundAmount, 2) }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Cancellation Reason</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $reason }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Initiated Date</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $initiatedDate }}</td></tr>
            </table>

            <div style="margin:20px 0;text-align:center;">
                <a href="{{ url('/') }}/orders/{{ $orderId }}" style="display:inline-block;background:#ef4444;color:#fff;padding:12px 24px;border-radius:6px;text-decoration:none;font-weight:bold;">View Refund Status</a>
            </div>

            <p style="margin:16px 0;font-size:13px;color:#6b7280;">If you have any questions about your refund or the cancellation, please contact our support team through the LaundryHub app.</p>
        </div>

        <div style="border-top:1px solid #e5e7eb;padding:20px;background:#f9fafb;font-size:13px;color:#6b7280;">
            <p style="margin:0 0 8px;"><strong>What's next?</strong></p>
            <p style="margin:0 0 12px;">Your refund will appear in your account shortly. You can place a new order any time using the LaundryHub app.</p>
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
