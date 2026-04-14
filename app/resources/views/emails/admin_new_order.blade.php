<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>New Order Alert</title>
</head>
<body style="margin:0;padding:0;background:#f4f7fb;font-family:Arial,sans-serif;color:#1f2937;">
    <div style="max-width:640px;margin:24px auto;background:#ffffff;border:1px solid #e5e7eb;border-radius:10px;overflow:hidden;">
        <div style="background:#7c3aed;color:#ffffff;padding:16px 20px;font-size:20px;font-weight:700;">LaundryHub Admin Alert</div>
        <div style="padding:20px;line-height:1.6;">
            <h2 style="margin:0 0 12px;">New Order Received</h2>
            <p style="margin:0 0 16px;">A new order was just placed by {{ $customerName }}.</p>

            <table style="width:100%;border-collapse:collapse;">
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Order ID</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $displayOrderId }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Customer</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $customerName }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Service</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $serviceName }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Weight</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ number_format($weightKg, 2) }} kg</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Total</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">PHP {{ number_format($totalPrice, 2) }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Fulfillment</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $deliveryTypeLabel }}</td></tr>
                <tr><td style="padding:8px;border-top:1px solid #e5e7eb;"><strong>Pickup Date</strong></td><td style="padding:8px;border-top:1px solid #e5e7eb;">{{ $pickupDate ?? 'N/A' }}</td></tr>
            </table>

            <p style="margin:16px 0 0;">Please review and process this order in the admin dashboard.</p>
        </div>
    </div>
</body>
</html>
