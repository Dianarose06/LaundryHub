<?php

namespace App\Notifications;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class OrderStatusUpdated extends Notification implements ShouldQueue
{
    use Queueable;

    private int $orderId;
    private string $serviceName;
    private string $previousStatus;
    private string $nextStatus;
    private float $totalPrice;
    private ?string $deliveryType;

    /**
     * Create a new notification instance.
     */
    public function __construct(Order $order, string $previousStatus, string $nextStatus)
    {
        $order->loadMissing('service');

        $this->orderId = (int) $order->id;
        $this->serviceName = (string) ($order->service?->name ?? 'Laundry Service');
        $this->previousStatus = $previousStatus;
        $this->nextStatus = $nextStatus;
        $this->totalPrice = (float) $order->total_price;
        $this->deliveryType = $order->delivery_type;
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
        $formattedPreviousStatus = $this->formatStatus($this->previousStatus);
        $formattedNextStatus = $this->formatStatus($this->nextStatus);
        $deliveryTypeLabel = $this->deliveryType === 'delivery' ? 'Delivery' : 'Pickup';

        return (new MailMessage)
            ->subject("LaundryHub Update: Order {$displayOrderId} is now {$formattedNextStatus}")
            ->view('emails.order_status_updated', [
                'customerName' => (string) ($notifiable->name ?? 'Customer'),
                'displayOrderId' => $displayOrderId,
                'orderId' => $this->orderId,
                'customerEmail' => (string) ($notifiable->email ?? ''),
                'serviceName' => $this->serviceName,
                'fromStatus' => $formattedPreviousStatus,
                'toStatus' => $formattedNextStatus,
                'deliveryTypeLabel' => $deliveryTypeLabel,
                'totalPrice' => $this->totalPrice,
            ]);
    }

    private function formatStatus(string $status): string
    {
        return ucfirst(strtolower(trim($status)));
    }
}