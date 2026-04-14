<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Payment Receipt</title>
</head>
<body style="margin:0;padding:0;background:#f4f7fb;font-family:Arial,sans-serif;color:#1f2937;">
    <div style="max-width:640px;margin:24px auto;background:#ffffff;border:1px solid #e5e7eb;border-radius:10px;overflow:hidden;">
        <div style="background:#16a34a;color:#ffffff;padding:16px 20px;font-size:20px;font-weight:700;">LaundryHub Receipt</div>
        <div style="padding:20px;line-height:1.6;">
            <h2 style="margin:0 0 12px;">Payment Received ✓</h2>
            <p style="margin:0 0 12px;">Hello {{ $customerName }}, your COD payment has been received.</p>
            <p style="margin:0 0 16px;"><strong>Order ID:</strong> {{ $displayOrderId }}</p>

            <table style="width:100%;border-collapse:collapse;">
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Service</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $serviceName }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Weight</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ number_format($weightKg, 2) }} kg</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Amount Paid</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">PHP {{ number_format($totalPrice, 2) }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Payment Method</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">Cash On Delivery (COD)</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Fulfillment</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $deliveryTypeLabel }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Transaction Date</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $completionDate }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Pickup Date</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $pickupDate ?? 'N/A' }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Delivery Date</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $deliveryDate ?? 'N/A' }}</td></tr>
            </table>

            <div style="margin:20px 0;padding:12px;background:#dcfce7;border-radius:6px;border-left:4px solid #16a34a;">
                <p style="margin:0;color:#166534;font-weight:bold;">✓ Your payment has been confirmed</p>
                <p style="margin:4px 0 0;color:#166534;font-size:13px;">Your order will be processed and delivered on schedule.</p>
            </div>

            <div style="margin:20px 0;text-align:center;">
                <a href="{{ url('/') }}/orders/{{ $orderId }}" style="display:inline-block;background:#16a34a;color:#fff;padding:12px 24px;border-radius:6px;text-decoration:none;font-weight:bold;">View Receipt & Track Order</a>
            </div>
        </div>
        
        <div style="border-top:1px solid #e5e7eb;padding:20px;background:#f9fafb;font-size:13px;color:#6b7280;">
            <p style="margin:0 0 8px;"><strong>Receipt Information</strong></p>
            <p style="margin:0 0 12px;">A copy of this receipt has been saved to your account for future reference.</p>
            <p style="margin:8px 0;">
                <a href="{{ url('/') }}/my-orders" style="color:#16a34a;text-decoration:none;">View All Orders</a> | 
                <a href="{{ url('/') }}/notifications-settings" style="color:#2563eb;text-decoration:none;">Manage Notifications</a>
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
