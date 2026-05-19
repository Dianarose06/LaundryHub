<?php

namespace Tests\Unit;

use App\Models\Order;
use App\Models\Service;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class ModelScopesTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_admins_scope_returns_only_admins(): void
    {
        User::factory()->create(['role' => 'admin']);
        User::factory()->create(['role' => 'customer']);

        $admins = User::admins()->get();

        $this->assertCount(1, $admins);
        $this->assertSame('admin', $admins->first()->role);
    }

    public function test_user_customers_scope_returns_only_customers(): void
    {
        User::factory()->create(['role' => 'admin']);
        User::factory()->create(['role' => 'customer']);
        User::factory()->create(['role' => 'customer']);

        $customers = User::customers()->get();

        $this->assertCount(2, $customers);
        $this->assertSame('customer', $customers->first()->role);
    }

    public function test_user_notifications_enabled_scope_filters_flag(): void
    {
        User::factory()->create(['notifications_enabled' => true]);
        User::factory()->create(['notifications_enabled' => false]);

        $users = User::notificationsEnabled()->get();

        $this->assertCount(1, $users);
        $this->assertTrue((bool) $users->first()->notifications_enabled);
    }

    public function test_order_by_status_scope(): void
    {
        Order::factory()->create(['status' => 'pending']);
        Order::factory()->create(['status' => 'completed']);

        $pending = Order::byStatus('pending')->get();

        $this->assertCount(1, $pending);
        $this->assertSame('pending', $pending->first()->status);
    }

    public function test_order_completed_today_scope(): void
    {
        $today = Carbon::today();
        $yesterday = $today->copy()->subDay();

        Order::factory()->create(['status' => 'completed', 'completed_at' => $today]);
        Order::factory()->create(['status' => 'completed', 'completed_at' => $yesterday]);
        Order::factory()->create(['status' => 'pending', 'completed_at' => $today]);

        $completedToday = Order::completedToday($today)->get();

        $this->assertCount(1, $completedToday);
        $this->assertSame('completed', $completedToday->first()->status);
    }

    public function test_order_pending_pickup_scope(): void
    {
        Order::factory()->create(['status' => 'pending', 'delivery_type' => 'pickup']);
        Order::factory()->create(['status' => 'pending', 'delivery_type' => 'delivery']);

        $pendingPickup = Order::pendingPickup()->get();

        $this->assertCount(1, $pendingPickup);
        $this->assertSame('pickup', $pendingPickup->first()->delivery_type);
    }

    public function test_order_display_id_accessor(): void
    {
        $order = Order::factory()->create();

        $this->assertSame('#LH-' . str_pad((string) $order->id, 3, '0', STR_PAD_LEFT), $order->display_id);
    }

    public function test_service_active_scope(): void
    {
        $activeService = Service::factory()->create(['is_active' => true]);
        $inactive = Service::factory()->create();
        DB::table('services')->where('id', $inactive->id)->update(['is_active' => 0]);

        $active = Service::active()->get();

        $this->assertTrue($active->contains('id', $activeService->id));
        $this->assertFalse($active->contains('id', $inactive->id));
    }
}
