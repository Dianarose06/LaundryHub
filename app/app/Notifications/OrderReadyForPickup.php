<?php

namespace App\Notifications;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class OrderReadyForPickup extends Notification implements ShouldQueue
{
    use Queueable;

    private int $orderId;
    private string $serviceName;
    private float $totalPrice;
    private ?string $pickupDate;
    private ?string $pickupTime;
    private string $readyDate;

    /**
     * Create a new notification instance.
     */
    public function __construct(Order $order)
    {
        $order->loadMissing('service');

        $this->orderId = (int) $order->id;
        $this->serviceName = (string) ($order->service?->name ?? 'Laundry Service');
        $this->totalPrice = (float) $order->total_price;
        $this->pickupDate = $order->pickup_date ? (is_string($order->pickup_date) ? $order->pickup_date : $order->pickup_date->format('M d, Y')) : null;
        $this->pickupTime = $order->pickup_time;
        $this->readyDate = now()->format('M d, Y h:i A');
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
            ->subject("LaundryHub Order Ready for Pickup: {$displayOrderId}")
            ->view('emails.order_ready_for_pickup', [
                'customerName' => (string) ($notifiable->name ?? 'Customer'),
                'displayOrderId' => $displayOrderId,
                'orderId' => $this->orderId,
                'serviceName' => $this->serviceName,
                'totalPrice' => $this->totalPrice,
                'pickupDate' => $this->pickupDate,
                'pickupTime' => $this->pickupTime,
                'readyDate' => $this->readyDate,
                'customerEmail' => $notifiable->email,
            ]);
    }
}
