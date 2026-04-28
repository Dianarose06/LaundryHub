<?php

namespace Tests\Feature;

use App\Models\Barangay;
use App\Models\Order;
use App\Models\Service;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class BarangayLogisticsFeesTest extends TestCase
{
    use RefreshDatabase;

    public function test_barangays_endpoint_returns_tacloban_data_with_official_names(): void
    {
        $response = $this->getJson('/api/barangays');

        $response->assertOk()
            ->assertJsonPath('meta.city', 'Tacloban City, Leyte')
            ->assertJsonPath('meta.logistics_fee_explanation.delivery_can_be_higher', true)
            ->assertJsonFragment([
                'name' => 'Barangay 47',
                'old_name' => 'Independencia',
                'display_name' => 'Barangay 47 (Independencia)',
            ]);

        $this->assertSame(82, count($response->json('data', [])));

        $barangayNames = collect($response->json('data', []))
            ->pluck('name')
            ->all();

        $this->assertContains('Barangay 20', $barangayNames);
        $this->assertContains('Barangay 59-A', $barangayNames);
        $this->assertContains('Barangay 80', $barangayNames);
        $this->assertNotContains('Barangay 1', $barangayNames);
        $this->assertNotContains('Barangay 109', $barangayNames);

        $barangaysByName = collect($response->json('data', []))->keyBy('name');

        $this->assertSame('Barangay 20', $barangaysByName['Barangay 20']['display_name']);
        $this->assertArrayHasKey('old_name', $barangaysByName['Barangay 80']);
        $this->assertStringStartsWith('Barangay 80', $barangaysByName['Barangay 80']['display_name']);
    }

    public function test_pickup_order_uses_zone_fee_from_selected_barangay(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $service = Service::factory()->create([
            'name' => 'Soft Wash',
            'price_per_kg' => 80.00,
        ]);

        $barangay = Barangay::query()
            ->where('name', 'Barangay 47')
            ->firstOrFail();

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $service->id,
            'weight_kg' => 8,
            'pickup_address' => 'Independencia Street',
            'pickup_barangay_id' => $barangay->id,
            'pickup_city' => 'Tacloban City, Leyte',
            'delivery_type' => 'pickup',
        ]);

        $response->assertCreated()
            ->assertJsonPath('meta.logistics_fee_explanation.delivery_can_be_higher', true);

        $order = Order::findOrFail($response->json('data.id'));

        $this->assertSame($barangay->id, (int) $order->pickup_barangay_id);
        $this->assertSame('Tacloban City, Leyte', (string) $order->pickup_city);
        $this->assertSame('Barangay 47', (string) $order->pickup_barangay);
        $this->assertSame('Zone 1', (string) $order->fee_zone);
        $this->assertSame(20.0, (float) $order->pickup_fee);
        $this->assertSame(30.0, (float) $order->delivery_fee);
        $this->assertSame(130.0, (float) $order->total_price);
    }

    public function test_drop_off_order_zeroes_pickup_fee_but_keeps_zone_delivery_fee(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $service = Service::factory()->create([
            'name' => 'Express Wash',
            'price_per_kg' => 80.00,
        ]);

        $barangay = Barangay::query()
            ->where('name', 'Barangay 80')
            ->firstOrFail();

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $service->id,
            'weight_kg' => 8,
            'pickup_address' => 'Tacloban Pier Area',
            'pickup_barangay_id' => $barangay->id,
            'pickup_city' => 'Tacloban City, Leyte',
            'delivery_type' => 'delivery',
        ]);

        $response->assertCreated();

        $order = Order::findOrFail($response->json('data.id'));

        $this->assertSame('Zone 2', (string) $order->fee_zone);
        $this->assertSame(0.0, (float) $order->pickup_fee);
        $this->assertSame(50.0, (float) $order->delivery_fee);
        $this->assertSame(130.0, (float) $order->total_price);
    }

    public function test_uncovered_far_barangay_is_removed_and_rejected_for_order_creation(): void
    {
        $this->assertDatabaseMissing('barangays', [
            'city' => 'Tacloban City, Leyte',
            'name' => 'Barangay 1',
        ]);

        $customer = User::factory()->create(['role' => 'customer']);
        $service = Service::factory()->create([
            'name' => 'Express Wash',
            'price_per_kg' => 80.00,
        ]);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $service->id,
            'weight_kg' => 8,
            'pickup_address' => 'Tacloban Pier Area',
            'pickup_barangay_id' => 1,
            'pickup_city' => 'Tacloban City, Leyte',
            'delivery_type' => 'pickup',
        ]);

        $response
            ->assertStatus(422)
            ->assertJsonValidationErrors('pickup_barangay_id');
    }

    public function test_non_tacloban_city_is_rejected_if_city_is_sent(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $service = Service::factory()->create([
            'name' => 'Wash-Dry-Fold',
            'price_per_kg' => 80.00,
        ]);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $service->id,
            'weight_kg' => 8,
            'pickup_address' => 'Some Street',
            'pickup_city' => 'Ormoc City, Leyte',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('pickup_city');
    }
}
