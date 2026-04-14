<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\Service;
use App\Models\User;
use App\Notifications\AdminNewOrderPlaced;
use App\Notifications\OrderConfirmation;
use App\Notifications\OrderPaymentReceipt;
use App\Notifications\OrderReadyForPickup;
use App\Notifications\OrderDeliveryScheduled;
use App\Notifications\OrderRefundInitiated;
use App\Notifications\OrderStatusUpdated;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Notification;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OrderEmailNotificationsTest extends TestCase
{
    use RefreshDatabase;

    public function test_order_confirmation_email_sent_on_order_creation(): void
    {
        Notification::fake();

        $customer = User::factory()->create(['role' => 'customer', 'notifications_enabled' => true]);
        $admin = User::factory()->create(['role' => 'admin', 'notifications_enabled' => true]);
        $service = Service::factory()->create(['name' => 'Wash & Fold']);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $service->id,
            'weight_kg' => 5,
            'pickup_address' => '123 Main St',
            'pickup_date' => '2026-04-20',
            'pickup_time' => '10:00',
            'delivery_type' => 'pickup',
        ]);

        $response->assertCreated();

        Notification::assertSentTo($customer, OrderConfirmation::class);
        Notification::assertSentTo($admin, AdminNewOrderPlaced::class);
    }

    public function test_customer_opt_out_blocks_customer_order_emails(): void
    {
        Notification::fake();

        $customer = User::factory()->create(['role' => 'customer', 'notifications_enabled' => false]);
        $admin = User::factory()->create(['role' => 'admin', 'notifications_enabled' => true]);
        $service = Service::factory()->create(['name' => 'Wash & Fold']);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $service->id,
            'weight_kg' => 3,
            'pickup_address' => '123 Main St',
        ]);

        $response->assertCreated();

        Notification::assertNotSentTo($customer, OrderConfirmation::class);
        Notification::assertSentTo($admin, AdminNewOrderPlaced::class);
    }

    public function test_admin_opt_out_blocks_admin_new_order_email(): void
    {
        Notification::fake();

        $customer = User::factory()->create(['role' => 'customer', 'notifications_enabled' => true]);
        $adminOptOut = User::factory()->create(['role' => 'admin', 'notifications_enabled' => false]);
        $adminOptIn = User::factory()->create(['role' => 'admin', 'notifications_enabled' => true]);
        $service = Service::factory()->create(['name' => 'Express Wash']);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $service->id,
            'weight_kg' => 2,
            'pickup_address' => '456 Oak Ave',
        ]);

        $response->assertCreated();

        Notification::assertNotSentTo($adminOptOut, AdminNewOrderPlaced::class);
        Notification::assertSentTo($adminOptIn, AdminNewOrderPlaced::class);
    }

    public function test_payment_receipt_email_sent_when_order_completed(): void
    {
        Notification::fake();

        $admin = User::factory()->create(['role' => 'admin']);
        $customer = User::factory()->create(['role' => 'customer']);
        $service = Service::factory()->create(['name' => 'Dry Cleaning']);

        $order = Order::factory()->create([
            'user_id' => $customer->id,
            'service_id' => $service->id,
            'status' => 'ready',
        ]);

        Sanctum::actingAs($admin);

        $response = $this->patchJson("/api/admin/orders/{$order->id}/status", [
            'status' => 'completed',
        ]);

        $response->assertOk();
        $this->assertSame('completed', $order->fresh()->status);

        Notification::assertSentTo($customer, OrderPaymentReceipt::class);
    }

    public function test_payment_receipt_respects_customer_opt_out(): void
    {
        Notification::fake();

        $admin = User::factory()->create(['role' => 'admin', 'notifications_enabled' => true]);
        $customer = User::factory()->create(['role' => 'customer', 'notifications_enabled' => false]);
        $service = Service::factory()->create(['name' => 'Dry Cleaning']);

        $order = Order::factory()->create([
            'user_id' => $customer->id,
            'service_id' => $service->id,
            'status' => 'ready',
        ]);

        Sanctum::actingAs($admin);

        $response = $this->patchJson("/api/admin/orders/{$order->id}/status", [
            'status' => 'completed',
        ]);

        $response->assertOk();

        Notification::assertNotSentTo($customer, OrderPaymentReceipt::class);
    }

    public function test_no_payment_receipt_when_changing_to_non_completed_status(): void
    {
        Notification::fake();

        $admin = User::factory()->create(['role' => 'admin']);
        $customer = User::factory()->create(['role' => 'customer']);
        $service = Service::factory()->create(['name' => 'Express Wash']);

        $order = Order::factory()->create([
            'user_id' => $customer->id,
            'service_id' => $service->id,
            'status' => 'pending',
        ]);

        Sanctum::actingAs($admin);

        $response = $this->patchJson("/api/admin/orders/{$order->id}/status", [
            'status' => 'ongoing',
        ]);

        $response->assertOk();

        Notification::assertNotSentTo($customer, OrderPaymentReceipt::class);
    }

    public function test_order_ready_for_pickup_email_sent(): void
    {
        Notification::fake();

        $admin = User::factory()->create(['role' => 'admin']);
        $customer = User::factory()->create(['role' => 'customer', 'notifications_enabled' => true]);
        $service = Service::factory()->create(['name' => 'Wash & Fold']);

        $order = Order::factory()->create([
            'user_id' => $customer->id,
            'service_id' => $service->id,
            'status' => 'ongoing',
            'delivery_type' => 'pickup',
            'pickup_date' => '2026-04-20',
            'pickup_time' => '14:00',
        ]);

        Sanctum::actingAs($admin);

        $response = $this->patchJson("/api/admin/orders/{$order->id}/status", [
            'status' => 'ready',
        ]);

        $response->assertOk();
        $this->assertSame('ready', $order->fresh()->status);

        Notification::assertSentTo($customer, OrderReadyForPickup::class);
        Notification::assertSentTo($customer, OrderStatusUpdated::class);
    }

    public function test_order_ready_for_pickup_respects_opt_out(): void
    {
        Notification::fake();

        $admin = User::factory()->create(['role' => 'admin']);
        $customer = User::factory()->create(['role' => 'customer', 'notifications_enabled' => false]);
        $service = Service::factory()->create(['name' => 'Express Wash']);

        $order = Order::factory()->create([
            'user_id' => $customer->id,
            'service_id' => $service->id,
            'status' => 'ongoing',
            'delivery_type' => 'pickup',
        ]);

        Sanctum::actingAs($admin);

        $response = $this->patchJson("/api/admin/orders/{$order->id}/status", [
            'status' => 'ready',
        ]);

        $response->assertOk();

        Notification::assertNotSentTo($customer, OrderReadyForPickup::class);
    }

    public function test_order_delivery_scheduled_email_sent(): void
    {
        Notification::fake();

        $admin = User::factory()->create(['role' => 'admin']);
        $customer = User::factory()->create(['role' => 'customer', 'notifications_enabled' => true]);
        $service = Service::factory()->create(['name' => 'Wash & Fold']);

        $order = Order::factory()->create([
            'user_id' => $customer->id,
            'service_id' => $service->id,
            'status' => 'ongoing',
            'delivery_type' => 'delivery',
            'delivery_date' => '2026-04-22',
        ]);

        Sanctum::actingAs($admin);

        $response = $this->patchJson("/api/admin/orders/{$order->id}/status", [
            'status' => 'ready',
        ]);

        $response->assertOk();

        Notification::assertSentTo($customer, OrderDeliveryScheduled::class);
    }

    public function test_order_refund_initiated_email_sent(): void
    {
        Notification::fake();

        $customer = User::factory()->create(['role' => 'customer', 'notifications_enabled' => true]);
        $service = Service::factory()->create(['name' => 'Dry Cleaning']);

        $order = Order::factory()->create([
            'user_id' => $customer->id,
            'service_id' => $service->id,
            'status' => 'pending',
            'total_price' => 500.00,
        ]);

        Sanctum::actingAs($customer);

        $response = $this->patchJson("/api/orders/{$order->id}/cancel");

        $response->assertOk();
        $this->assertSame('cancelled', $order->fresh()->status);

        Notification::assertSentTo($customer, OrderRefundInitiated::class);
        Notification::assertSentTo($customer, OrderStatusUpdated::class);
    }

    public function test_refund_notification_respects_opt_out(): void
    {
        Notification::fake();

        $customer = User::factory()->create(['role' => 'customer', 'notifications_enabled' => false]);
        $service = Service::factory()->create(['name' => 'Soft Wash']);

        $order = Order::factory()->create([
            'user_id' => $customer->id,
            'service_id' => $service->id,
            'status' => 'pending',
        ]);

        Sanctum::actingAs($customer);

        $response = $this->patchJson("/api/orders/{$order->id}/cancel");

        $response->assertOk();

        Notification::assertNotSentTo($customer, OrderRefundInitiated::class);
    }
}

