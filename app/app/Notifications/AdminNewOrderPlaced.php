<?php

namespace App\Notifications;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class AdminNewOrderPlaced extends Notification implements ShouldQueue
{
    use Queueable;

    private int $orderId;
    private string $customerName;
    private string $serviceName;
    private float $weightKg;
    private float $totalPrice;
    private string $deliveryTypeLabel;
    private ?string $pickupDate;

    /**
     * Create a new notification instance.
     */
    public function __construct(Order $order)
    {
        $order->loadMissing(['user', 'service']);

        $this->orderId = (int) $order->id;
        $this->customerName = (string) ($order->user?->name ?? 'Customer');
        $this->serviceName = (string) ($order->service?->name ?? 'Laundry Service');
        $this->weightKg = (float) $order->weight_kg;
        $this->totalPrice = (float) $order->total_price;
        $this->deliveryTypeLabel = ($order->delivery_type ?? 'pickup') === 'delivery' ? 'Delivery' : 'Pickup';
        $this->pickupDate = $order->pickup_date ? (is_string($order->pickup_date) ? $order->pickup_date : $order->pickup_date->format('M d, Y')) : null;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via($notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail($notifiable): MailMessage
    {
        $displayOrderId = '#LH-' . str_pad((string) $this->orderId, 3, '0', STR_PAD_LEFT);

        return (new MailMessage)
            ->subject("LaundryHub Admin Alert: New Order {$displayOrderId}")
            ->view('emails.admin_new_order', [
                'displayOrderId' => $displayOrderId,
                'customerName' => $this->customerName,
                'serviceName' => $this->serviceName,
                'weightKg' => $this->weightKg,
                'totalPrice' => $this->totalPrice,
                'deliveryTypeLabel' => $this->deliveryTypeLabel,
                'pickupDate' => $this->pickupDate,
            ]);
    }
}
