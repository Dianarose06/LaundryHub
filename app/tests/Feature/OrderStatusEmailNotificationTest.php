<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\Service;
use App\Models\User;
use App\Notifications\OrderStatusUpdated;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Notification;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OrderStatusEmailNotificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_status_update_sends_order_status_email_notification(): void
    {
        Notification::fake();

        $admin = User::factory()->create(['role' => 'admin']);
        $customer = User::factory()->create(['role' => 'customer']);
        $service = Service::factory()->create(['name' => 'Dry Cleaning']);

        $order = Order::factory()->create([
            'user_id' => $customer->id,
            'service_id' => $service->id,
            'status' => 'pending',
        ]);

        Sanctum::actingAs($admin);

        $response = $this->patchJson("/api/admin/orders/{$order->id}/status", [
            'status' => 'ready',
        ]);

        $response->assertOk();
        $this->assertSame('ready', $order->fresh()->status);

        Notification::assertSentTo($customer, OrderStatusUpdated::class);
    }

    public function test_customer_cancel_sends_order_status_email_notification(): void
    {
        Notification::fake();

        $customer = User::factory()->create(['role' => 'customer']);
        $service = Service::factory()->create(['name' => 'Express Laundry']);

        $order = Order::factory()->create([
            'user_id' => $customer->id,
            'service_id' => $service->id,
            'status' => 'pending',
        ]);

        Sanctum::actingAs($customer);

        $response = $this->patchJson("/api/orders/{$order->id}/cancel");

        $response->assertOk();
        $this->assertSame('cancelled', $order->fresh()->status);

        Notification::assertSentTo($customer, OrderStatusUpdated::class);
    }
}