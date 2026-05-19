<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\Service;
use App\Models\User;
use App\Notifications\OrderDeliveryScheduled;
use App\Notifications\OrderPaymentReceipt;
use App\Notifications\OrderReadyForPickup;
use App\Notifications\OrderRefundInitiated;
use App\Notifications\OrderStatusUpdated;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Notification;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminControllerTest extends TestCase
{
    use RefreshDatabase;

    private function actingAsAdmin(): User
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'notifications_enabled' => true,
        ]);

        Sanctum::actingAs($admin);

        return $admin;
    }

    private function createCustomer(array $overrides = []): User
    {
        return User::factory()->create(array_merge([
            'role' => 'customer',
            'notifications_enabled' => true,
            'loyalty_points' => 0,
        ], $overrides));
    }

    private function createOrder(User $customer, Service $service, array $overrides = []): Order
    {
        return Order::factory()->create(array_merge([
            'user_id' => $customer->id,
            'service_id' => $service->id,
        ], $overrides));
    }

    public function test_stats_returns_expected_totals(): void
    {
        $this->actingAsAdmin();

        $service = Service::factory()->create();
        $customerA = $this->createCustomer();
        $customerB = $this->createCustomer();

        $today = Carbon::today();

        $this->createOrder($customerA, $service, ['status' => 'pending']);
        $this->createOrder($customerA, $service, ['status' => 'pending']);
        $this->createOrder($customerA, $service, [
            'status' => 'completed',
            'completed_at' => $today,
            'total_price' => 150,
        ]);
        $this->createOrder($customerB, $service, [
            'status' => 'completed',
            'completed_at' => $today->copy()->subDay(),
            'total_price' => 200,
        ]);
        $this->createOrder($customerB, $service, ['status' => 'ready']);

        $response = $this->getJson('/api/admin/stats');

        $response->assertOk();
        $response->assertJson([
            'total_bookings' => 5,
            'pending_count' => 2,
            'revenue_today' => 150.0,
            'customer_count' => 2,
        ]);
    }

    public function test_recent_orders_returns_latest_five(): void
    {
        $this->actingAsAdmin();

        $service = Service::factory()->create(['name' => 'Wash & Fold']);
        $customer = $this->createCustomer(['name' => 'Test Customer']);

        foreach (range(0, 5) as $offset) {
            $this->createOrder($customer, $service, [
                'created_at' => now()->subMinutes($offset),
                'status' => 'pending',
            ]);
        }

        $response = $this->getJson('/api/admin/orders/recent');

        $response->assertOk();
        $response->assertJsonCount(5, 'data');
        $response->assertJsonStructure([
            'data' => [
                '*' => [
                    'order_id',
                    'id',
                    'customer_name',
                    'service_type',
                    'service_emoji',
                    'weight_kg',
                    'pickup_address',
                    'pickup_date',
                    'delivery_date',
                    'delivery_type',
                    'total_price',
                    'status',
                ],
            ],
        ]);
    }

    public function test_orders_endpoint_filters_by_status(): void
    {
        $this->actingAsAdmin();

        $service = Service::factory()->create();
        $customer = $this->createCustomer();

        $this->createOrder($customer, $service, ['status' => 'pending']);
        $this->createOrder($customer, $service, ['status' => 'completed']);

        $response = $this->getJson('/api/admin/orders?status=pending&per_page=10');

        $response->assertOk();
        $response->assertJsonCount(1, 'data');
        $response->assertJsonPath('data.0.status', 'Pending');
        $response->assertJsonStructure([
            'data',
            'pagination' => ['total', 'count', 'per_page', 'current_page', 'last_page'],
        ]);
    }

    public function test_booking_summaries_returns_status_counts(): void
    {
        $this->actingAsAdmin();

        $service = Service::factory()->create();
        $customer = $this->createCustomer();

        $this->createOrder($customer, $service, ['status' => 'pending']);
        $this->createOrder($customer, $service, ['status' => 'ongoing']);
        $this->createOrder($customer, $service, ['status' => 'ready']);
        $this->createOrder($customer, $service, ['status' => 'completed']);
        $this->createOrder($customer, $service, ['status' => 'cancelled']);

        $response = $this->getJson('/api/admin/booking-summaries');

        $response->assertOk();
        $response->assertJsonPath('data.total', 5);
        $response->assertJsonPath('data.by_status.pending', 1);
        $response->assertJsonPath('data.by_status.ongoing', 1);
        $response->assertJsonPath('data.by_status.ready', 1);
        $response->assertJsonPath('data.by_status.completed', 1);
        $response->assertJsonPath('data.by_status.cancelled', 1);
        $response->assertJsonPath('data.accepted_bookings', 2);
    }

    public function test_update_order_status_awards_loyalty_points_and_receipt(): void
    {
        $this->actingAsAdmin();
        Notification::fake();

        $service = Service::factory()->create();
        $customer = $this->createCustomer(['loyalty_points' => 0]);
        $order = $this->createOrder($customer, $service, [
            'status' => 'pending',
            'total_price' => 250,
            'delivery_type' => 'pickup',
        ]);

        $response = $this->patchJson("/api/admin/orders/{$order->id}/status", [
            'status' => 'completed',
        ]);

        $response->assertOk();
        $response->assertJsonPath('loyalty_points_awarded', 2);
        $response->assertJsonPath('customer_loyalty_points', 2);

        $order->refresh();
        $customer->refresh();

        $this->assertSame('completed', $order->status);
        $this->assertNotNull($order->completed_at);
        $this->assertSame(2, $customer->loyalty_points);

        Notification::assertSentTo($customer, OrderStatusUpdated::class);
        Notification::assertSentTo($customer, OrderPaymentReceipt::class);
    }

    public function test_update_order_status_ready_sends_delivery_scheduled(): void
    {
        $this->actingAsAdmin();
        Notification::fake();

        $service = Service::factory()->create();
        $customer = $this->createCustomer();
        $order = $this->createOrder($customer, $service, [
            'status' => 'ongoing',
            'delivery_type' => 'delivery',
        ]);

        $response = $this->patchJson("/api/admin/orders/{$order->id}/status", [
            'status' => 'ready',
        ]);

        $response->assertOk();

        Notification::assertSentTo($customer, OrderDeliveryScheduled::class);
    }

    public function test_update_order_status_ready_sends_ready_for_pickup(): void
    {
        $this->actingAsAdmin();
        Notification::fake();

        $service = Service::factory()->create();
        $customer = $this->createCustomer();
        $order = $this->createOrder($customer, $service, [
            'status' => 'ongoing',
            'delivery_type' => 'pickup',
        ]);

        $response = $this->patchJson("/api/admin/orders/{$order->id}/status", [
            'status' => 'ready',
        ]);

        $response->assertOk();

        Notification::assertSentTo($customer, OrderReadyForPickup::class);
    }

    public function test_update_order_status_cancelled_sends_refund_notification(): void
    {
        $this->actingAsAdmin();
        Notification::fake();

        $service = Service::factory()->create();
        $customer = $this->createCustomer();
        $order = $this->createOrder($customer, $service, [
            'status' => 'ongoing',
        ]);

        $response = $this->patchJson("/api/admin/orders/{$order->id}/status", [
            'status' => 'cancelled',
        ]);

        $response->assertOk();

        Notification::assertSentTo($customer, OrderRefundInitiated::class);
    }

    public function test_non_admin_cannot_access_admin_routes(): void
    {
        $customer = $this->createCustomer();
        Sanctum::actingAs($customer);

        $response = $this->getJson('/api/admin/stats');

        $response->assertForbidden();
    }
}
