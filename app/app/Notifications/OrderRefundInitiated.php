<?php

namespace App\Notifications;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class OrderRefundInitiated extends Notification implements ShouldQueue
{
    use Queueable;

    private int $orderId;
    private string $serviceName;
    private float $refundAmount;
    private string $reason;
    private string $initiatedDate;

    /**
     * Create a new notification instance.
     */
    public function __construct(Order $order, string $reason = 'Customer requested cancellation')
    {
        $order->loadMissing('service');

        $this->orderId = (int) $order->id;
        $this->serviceName = (string) ($order->service?->name ?? 'Laundry Service');
        $this->refundAmount = (float) $order->total_price;
        $this->reason = $reason;
        $this->initiatedDate = now()->format('M d, Y h:i A');
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
            ->subject("LaundryHub Order Cancelled & Refund Initiated: {$displayOrderId}")
            ->view('emails.order_refund_initiated', [
                'customerName' => (string) ($notifiable->name ?? 'Customer'),
                'displayOrderId' => $displayOrderId,
                'orderId' => $this->orderId,
                'serviceName' => $this->serviceName,
                'refundAmount' => $this->refundAmount,
                'reason' => $this->reason,
                'initiatedDate' => $this->initiatedDate,
                'customerEmail' => $notifiable->email,
            ]);
    }
}
