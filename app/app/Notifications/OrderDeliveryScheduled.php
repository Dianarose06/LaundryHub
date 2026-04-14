<?php

namespace App\Notifications;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class OrderDeliveryScheduled extends Notification implements ShouldQueue
{
    use Queueable;

    private int $orderId;
    private string $serviceName;
    private float $totalPrice;
    private ?string $deliveryDate;
    private ?string $deliveryTime;
    private string $deliveryAddress;
    private string $scheduledDate;

    /**
     * Create a new notification instance.
     */
    public function __construct(Order $order, ?string $deliveryTime = null)
    {
        $order->loadMissing('service');

        $this->orderId = (int) $order->id;
        $this->serviceName = (string) ($order->service?->name ?? 'Laundry Service');
        $this->totalPrice = (float) $order->total_price;
        $this->deliveryDate = $order->delivery_date ? (is_string($order->delivery_date) ? $order->delivery_date : $order->delivery_date->format('M d, Y')) : null;
        $this->deliveryTime = $deliveryTime ?? '9:00 AM - 5:00 PM';
        $this->deliveryAddress = (string) ($order->delivery_address ?? 'Your address');
        $this->scheduledDate = now()->format('M d, Y h:i A');
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
            ->subject("LaundryHub Delivery Scheduled: {$displayOrderId}")
            ->view('emails.order_delivery_scheduled', [
                'customerName' => (string) ($notifiable->name ?? 'Customer'),
                'displayOrderId' => $displayOrderId,
                'orderId' => $this->orderId,
                'serviceName' => $this->serviceName,
                'totalPrice' => $this->totalPrice,
                'deliveryDate' => $this->deliveryDate,
                'deliveryTime' => $this->deliveryTime,
                'deliveryAddress' => $this->deliveryAddress,
                'scheduledDate' => $this->scheduledDate,
                'customerEmail' => $notifiable->email,
            ]);
    }
}
