<?php

namespace App\Notifications;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class OrderPaymentReceipt extends Notification implements ShouldQueue
{
    use Queueable;

    private int $orderId;
    private string $serviceName;
    private float $weightKg;
    private float $totalPrice;
    private ?string $pickupDate;
    private ?string $deliveryDate;
    private ?string $deliveryType;
    private string $completionDate;

    /**
     * Create a new notification instance.
     */
    public function __construct(Order $order)
    {
        $order->loadMissing('service');

        $this->orderId = (int) $order->id;
        $this->serviceName = (string) ($order->service?->name ?? 'Laundry Service');
        $this->weightKg = (float) $order->weight_kg;
        $this->totalPrice = (float) $order->total_price;
        $this->pickupDate = $order->pickup_date ? (is_string($order->pickup_date) ? $order->pickup_date : $order->pickup_date->format('M d, Y')) : null;
        $this->deliveryDate = $order->delivery_date ? (is_string($order->delivery_date) ? $order->delivery_date : $order->delivery_date->format('M d, Y')) : null;
        $this->deliveryType = $order->delivery_type ?? 'pickup';
        $this->completionDate = now()->format('M d, Y h:i A');
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
        $deliveryTypeLabel = $this->deliveryType === 'delivery' ? 'Delivery' : 'Pickup';

        return (new MailMessage)
            ->subject("LaundryHub Receipt: Order {$displayOrderId} Completed & Paid")
            ->view('emails.order_payment_receipt', [
                'customerName' => (string) ($notifiable->name ?? 'Customer'),
                'displayOrderId' => $displayOrderId,
                'orderId' => $this->orderId,
                'customerEmail' => (string) ($notifiable->email ?? ''),
                'serviceName' => $this->serviceName,
                'weightKg' => $this->weightKg,
                'totalPrice' => $this->totalPrice,
                'deliveryTypeLabel' => $deliveryTypeLabel,
                'completionDate' => $this->completionDate,
                'pickupDate' => $this->pickupDate,
                'deliveryDate' => $this->deliveryDate,
            ]);
    }
}
