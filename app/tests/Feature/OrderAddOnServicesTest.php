<?php

namespace Tests\Feature;

use App\Models\AddOnService;
use App\Models\Order;
use App\Models\Service;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OrderAddOnServicesTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_can_create_order_with_add_ons_and_total_is_calculated(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $service = Service::factory()->create([
            'name' => 'Wash-Dry-Fold',
            'price_per_kg' => 24.00,
        ]);

        $fabricSoftener = AddOnService::factory()->create([
            'name' => 'Fabric Softener',
            'fee' => 15.00,
            'is_active' => true,
        ]);

        $stainRemoval = AddOnService::factory()->create([
            'name' => 'Stain Removal Treatment',
            'fee' => 20.00,
            'is_active' => true,
        ]);

        $ironing = AddOnService::factory()->create([
            'name' => 'Ironing',
            'fee' => 25.00,
            'is_active' => true,
        ]);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $service->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'add_ons' => [$fabricSoftener->id, $stainRemoval->id, $ironing->id],
        ]);

        $response->assertCreated();

        $order = Order::with('addOnServices')->findOrFail($response->json('data.id'));

        $this->assertSame(144.0, (float) $order->total_price);
        $this->assertSame(60.0, (float) $order->add_on_total);
        $this->assertCount(3, $order->addOnServices);

        $this->assertDatabaseHas('order_add_on_services', [
            'order_id' => $order->id,
            'add_on_service_id' => $fabricSoftener->id,
            'fee' => 15.00,
        ]);

        $this->assertDatabaseHas('order_add_on_services', [
            'order_id' => $order->id,
            'add_on_service_id' => $stainRemoval->id,
            'fee' => 20.00,
        ]);

        $this->assertDatabaseHas('order_add_on_services', [
            'order_id' => $order->id,
            'add_on_service_id' => $ironing->id,
            'fee' => 25.00,
        ]);
    }

    public function test_drop_off_order_excludes_pickup_fee_but_keeps_delivery_fee(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $service = Service::factory()->create([
            'name' => 'Express Wash',
            'price_per_kg' => 80.00,
        ]);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $service->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'delivery_type' => 'delivery',
        ]);

        $response->assertCreated();

        $order = Order::findOrFail($response->json('data.id'));

        $this->assertSame(0.0, (float) $order->add_on_total);
        $this->assertSame(110.0, (float) $order->total_price);
    }

    public function test_add_on_services_endpoint_includes_ironing_with_fixed_fee(): void
    {
        $response = $this->getJson('/api/add-on-services');

        $response->assertOk()
            ->assertJsonFragment([
                'name' => 'Ironing',
                'fee' => 25.0,
            ]);
    }

    public function test_add_on_services_endpoint_supports_page_and_per_page_query_params(): void
    {
        $service = Service::factory()->create([
            'name' => 'Paged Catalog Service',
            'price_per_kg' => 60.00,
        ]);

        foreach (range(1, 7) as $index) {
            AddOnService::factory()->create([
                'name' => sprintf('Paged Add-on %02d', $index),
                'fee' => 10 + $index,
                'is_active' => true,
                'service_id' => $service->id,
            ]);
        }

        $response = $this->getJson('/api/add-on-services?service_id='.$service->id.'&page=2&per_page=3');

        $response->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonPath('data.0.name', 'Paged Add-on 04')
            ->assertJsonPath('meta.current_page', 2)
            ->assertJsonPath('meta.per_page', 3)
            ->assertJsonPath('meta.total', 7)
            ->assertJsonPath('meta.last_page', 3)
            ->assertJsonPath('meta.from', 4)
            ->assertJsonPath('meta.to', 6)
            ->assertJsonPath('meta.has_more_pages', true);
    }

    public function test_add_on_services_endpoint_without_pagination_keeps_data_only_shape(): void
    {
        $service = Service::factory()->create([
            'name' => 'Non Paginated Catalog Service',
            'price_per_kg' => 55.00,
        ]);

        AddOnService::factory()->create([
            'name' => 'Non-Paged Add-on A',
            'fee' => 20,
            'is_active' => true,
            'service_id' => $service->id,
        ]);

        AddOnService::factory()->create([
            'name' => 'Non-Paged Add-on B',
            'fee' => 25,
            'is_active' => true,
            'service_id' => $service->id,
        ]);

        $response = $this->getJson('/api/add-on-services?service_id='.$service->id);

        $response->assertOk()
            ->assertJsonCount(2, 'data');

        $this->assertArrayNotHasKey('meta', $response->json());
    }

    public function test_add_on_services_endpoint_rejects_per_page_beyond_limit(): void
    {
        $response = $this->getJson('/api/add-on-services?page=1&per_page=101');

        $response
            ->assertStatus(422)
            ->assertJsonValidationErrors('per_page');
    }

    public function test_soft_wash_add_on_services_endpoint_uses_service_specific_catalog(): void
    {
        $softWash = Service::factory()->create([
            'name' => 'Soft Wash',
            'description' => 'Gentle washing cycle designed for delicate and sensitive fabrics.',
            'price_per_kg' => 75.00,
        ]);

        AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'fee' => 20.00,
            'is_active' => true,
            'service_id' => null,
        ]);

        AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'description' => 'Kills germs and bacteria in your delicate clothes. Ideal for baby clothes and sensitive skin.',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $softWash->id,
        ]);

        AddOnService::factory()->create([
            'name' => 'Fabric Softener',
            'description' => 'Makes your delicate clothes softer and leaves a fresh long-lasting scent.',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $softWash->id,
        ]);

        AddOnService::factory()->create([
            'name' => 'Stain Removal Treatment',
            'description' => 'Pre-treatment for tough stains like oil, blood, and ink on delicate fabrics before washing.',
            'fee' => 35.00,
            'is_active' => true,
            'service_id' => $softWash->id,
        ]);

        AddOnService::factory()->create([
            'name' => 'Ironing',
            'description' => 'Delicate clothes are neatly pressed and ironed after washing for a ready-to-wear finish.',
            'fee' => 50.00,
            'is_active' => true,
            'service_id' => $softWash->id,
        ]);

        $response = $this->getJson('/api/add-on-services?service_id='.$softWash->id);

        $response->assertOk()
            ->assertJsonCount(4, 'data')
            ->assertJsonFragment([
                'name' => 'Antibacterial Boost',
                'fee' => 30.0,
            ])
            ->assertJsonFragment([
                'name' => 'Fabric Softener',
                'fee' => 30.0,
            ])
            ->assertJsonFragment([
                'name' => 'Stain Removal Treatment',
                'fee' => 35.0,
            ])
            ->assertJsonFragment([
                'name' => 'Ironing',
                'fee' => 50.0,
            ]);

        $softWashCatalog = collect($response->json('data', []));

        $this->assertNull($softWashCatalog->first(
            fn (array $item) =>
                ($item['name'] ?? null) === 'Antibacterial Boost'
                && (float) ($item['fee'] ?? 0) === 20.0
        ));
    }

    public function test_soft_wash_order_uses_service_specific_add_on_fees(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $softWash = Service::factory()->create([
            'name' => 'Soft Wash',
            'description' => 'Gentle washing cycle designed for delicate and sensitive fabrics.',
            'price_per_kg' => 75.00,
        ]);

        $globalAntibacterial = AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'fee' => 20.00,
            'is_active' => true,
            'service_id' => null,
        ]);

        $softAntibacterial = AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $softWash->id,
        ]);

        $softIroning = AddOnService::factory()->create([
            'name' => 'Ironing',
            'fee' => 50.00,
            'is_active' => true,
            'service_id' => $softWash->id,
        ]);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $softWash->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'add_ons' => [$softAntibacterial->id, $softIroning->id],
        ]);

        $response->assertCreated();

        $order = Order::with('addOnServices')->findOrFail($response->json('data.id'));

        $this->assertSame(80.0, (float) $order->add_on_total);
        $this->assertSame(215.0, (float) $order->total_price);
        $this->assertCount(2, $order->addOnServices);

        $invalidResponse = $this->postJson('/api/orders', [
            'service_id' => $softWash->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'add_ons' => [$globalAntibacterial->id],
        ]);

        $invalidResponse
            ->assertStatus(422)
            ->assertJsonValidationErrors('add_ons');
    }

    public function test_beddings_add_on_services_endpoint_uses_service_specific_catalog(): void
    {
        $beddings = Service::factory()->create([
            'name' => 'Beddings',
            'description' => 'Specialized washing for bulky items like comforters, blankets, pillowcases, and bed sheets.',
            'price_per_kg' => 180.00,
        ]);

        AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'fee' => 20.00,
            'is_active' => true,
            'service_id' => null,
        ]);

        AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'description' => 'Kills germs, dust mites, and bacteria in your beddings for a cleaner and healthier sleep.',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $beddings->id,
        ]);

        AddOnService::factory()->create([
            'name' => 'Fabric Softener',
            'description' => 'Leaves your beddings feeling softer and smelling fresh for a more comfortable sleep.',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $beddings->id,
        ]);

        AddOnService::factory()->create([
            'name' => 'Stain Removal Treatment',
            'description' => 'Pre-treatment for tough stains on beddings like oil, blood, and food stains before washing.',
            'fee' => 35.00,
            'is_active' => true,
            'service_id' => $beddings->id,
        ]);

        $response = $this->getJson('/api/add-on-services?service_id='.$beddings->id);

        $response->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonFragment([
                'name' => 'Antibacterial Boost',
                'fee' => 30.0,
            ])
            ->assertJsonFragment([
                'name' => 'Fabric Softener',
                'fee' => 30.0,
            ])
            ->assertJsonFragment([
                'name' => 'Stain Removal Treatment',
                'fee' => 35.0,
            ]);

        $beddingsCatalog = collect($response->json('data', []));

        $this->assertNull($beddingsCatalog->first(
            fn (array $item) =>
                ($item['name'] ?? null) === 'Antibacterial Boost'
                && (float) ($item['fee'] ?? 0) === 20.0
        ));
    }

    public function test_beddings_order_uses_service_specific_add_on_fees(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $beddings = Service::factory()->create([
            'name' => 'Beddings',
            'description' => 'Specialized washing for bulky items like comforters, blankets, pillowcases, and bed sheets.',
            'price_per_kg' => 180.00,
        ]);

        $globalAntibacterial = AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'fee' => 20.00,
            'is_active' => true,
            'service_id' => null,
        ]);

        $beddingsAntibacterial = AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $beddings->id,
        ]);

        $beddingsStainRemoval = AddOnService::factory()->create([
            'name' => 'Stain Removal Treatment',
            'fee' => 35.00,
            'is_active' => true,
            'service_id' => $beddings->id,
        ]);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $beddings->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'add_ons' => [$beddingsAntibacterial->id, $beddingsStainRemoval->id],
        ]);

        $response->assertCreated();

        $order = Order::with('addOnServices')->findOrFail($response->json('data.id'));

        $this->assertSame(65.0, (float) $order->add_on_total);
        $this->assertSame(305.0, (float) $order->total_price);
        $this->assertCount(2, $order->addOnServices);

        $invalidResponse = $this->postJson('/api/orders', [
            'service_id' => $beddings->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'add_ons' => [$globalAntibacterial->id],
        ]);

        $invalidResponse
            ->assertStatus(422)
            ->assertJsonValidationErrors('add_ons');
    }

    public function test_wash_dry_fold_add_on_services_endpoint_uses_service_specific_catalog(): void
    {
        $washDryFold = Service::factory()->create([
            'name' => 'Wash-Dry-Fold',
            'description' => 'Standard washing, drying, and neatly folding of everyday clothes.',
            'price_per_kg' => 150.00,
        ]);

        AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'fee' => 20.00,
            'is_active' => true,
            'service_id' => null,
        ]);

        AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'description' => 'Kills germs and bacteria in your everyday clothes. Perfect for active and busy lifestyles.',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $washDryFold->id,
        ]);

        AddOnService::factory()->create([
            'name' => 'Fabric Softener',
            'description' => 'Makes your everyday clothes softer, reduces static, and leaves a fresh long-lasting scent.',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $washDryFold->id,
        ]);

        AddOnService::factory()->create([
            'name' => 'Stain Removal Treatment',
            'description' => 'Pre-treatment for tough stains like oil, blood, and ink on everyday clothes before washing.',
            'fee' => 35.00,
            'is_active' => true,
            'service_id' => $washDryFold->id,
        ]);

        AddOnService::factory()->create([
            'name' => 'Ironing',
            'description' => 'Everyday clothes are neatly pressed and ironed after washing for a ready-to-wear finish.',
            'fee' => 50.00,
            'is_active' => true,
            'service_id' => $washDryFold->id,
        ]);

        $response = $this->getJson('/api/add-on-services?service_id='.$washDryFold->id);

        $response->assertOk()
            ->assertJsonCount(4, 'data')
            ->assertJsonFragment([
                'name' => 'Antibacterial Boost',
                'fee' => 30.0,
            ])
            ->assertJsonFragment([
                'name' => 'Fabric Softener',
                'fee' => 30.0,
            ])
            ->assertJsonFragment([
                'name' => 'Stain Removal Treatment',
                'fee' => 35.0,
            ])
            ->assertJsonFragment([
                'name' => 'Ironing',
                'fee' => 50.0,
            ]);

        $washDryFoldCatalog = collect($response->json('data', []));

        $this->assertNull($washDryFoldCatalog->first(
            fn (array $item) =>
                ($item['name'] ?? null) === 'Antibacterial Boost'
                && (float) ($item['fee'] ?? 0) === 20.0
        ));
    }

    public function test_wash_dry_fold_order_uses_service_specific_add_on_fees(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $washDryFold = Service::factory()->create([
            'name' => 'Wash-Dry-Fold',
            'description' => 'Standard washing, drying, and neatly folding of everyday clothes.',
            'price_per_kg' => 150.00,
        ]);

        $globalAntibacterial = AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'fee' => 20.00,
            'is_active' => true,
            'service_id' => null,
        ]);

        $washDryFoldAntibacterial = AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $washDryFold->id,
        ]);

        $washDryFoldIroning = AddOnService::factory()->create([
            'name' => 'Ironing',
            'fee' => 50.00,
            'is_active' => true,
            'service_id' => $washDryFold->id,
        ]);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $washDryFold->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'add_ons' => [$washDryFoldAntibacterial->id, $washDryFoldIroning->id],
        ]);

        $response->assertCreated();

        $order = Order::with('addOnServices')->findOrFail($response->json('data.id'));

        $this->assertSame(80.0, (float) $order->add_on_total);
        $this->assertSame(290.0, (float) $order->total_price);
        $this->assertCount(2, $order->addOnServices);

        $invalidResponse = $this->postJson('/api/orders', [
            'service_id' => $washDryFold->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'add_ons' => [$globalAntibacterial->id],
        ]);

        $invalidResponse
            ->assertStatus(422)
            ->assertJsonValidationErrors('add_ons');
    }

    public function test_express_wash_add_on_services_endpoint_uses_service_specific_catalog(): void
    {
        $expressWash = Service::factory()->create([
            'name' => 'Express Wash',
            'description' => 'Need it fast? Your clothes are washed, dried, and folded in the shortest time possible.',
            'price_per_kg' => 200.00,
        ]);

        AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'fee' => 20.00,
            'is_active' => true,
            'service_id' => null,
        ]);

        AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'description' => 'Kills germs and bacteria in your everyday clothes. Perfect for active and busy lifestyles.',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $expressWash->id,
        ]);

        AddOnService::factory()->create([
            'name' => 'Fabric Softener',
            'description' => 'Makes your everyday clothes softer, reduces static, and leaves a fresh long-lasting scent.',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $expressWash->id,
        ]);

        AddOnService::factory()->create([
            'name' => 'Stain Removal Treatment',
            'description' => 'Pre-treatment for tough stains like oil, blood, and ink on everyday clothes before washing.',
            'fee' => 35.00,
            'is_active' => true,
            'service_id' => $expressWash->id,
        ]);

        $response = $this->getJson('/api/add-on-services?service_id='.$expressWash->id);

        $response->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonFragment([
                'name' => 'Antibacterial Boost',
                'fee' => 30.0,
            ])
            ->assertJsonFragment([
                'name' => 'Fabric Softener',
                'fee' => 30.0,
            ])
            ->assertJsonFragment([
                'name' => 'Stain Removal Treatment',
                'fee' => 35.0,
            ]);

        $expressCatalog = collect($response->json('data', []));

        $this->assertNull($expressCatalog->first(
            fn (array $item) =>
                ($item['name'] ?? null) === 'Antibacterial Boost'
                && (float) ($item['fee'] ?? 0) === 20.0
        ));
    }

    public function test_express_wash_order_uses_service_specific_add_on_fees(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $expressWash = Service::factory()->create([
            'name' => 'Express Wash',
            'description' => 'Need it fast? Your clothes are washed, dried, and folded in the shortest time possible.',
            'price_per_kg' => 200.00,
        ]);

        $globalAntibacterial = AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'fee' => 20.00,
            'is_active' => true,
            'service_id' => null,
        ]);

        $expressAntibacterial = AddOnService::factory()->create([
            'name' => 'Antibacterial Boost',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $expressWash->id,
        ]);

        $expressFabricSoftener = AddOnService::factory()->create([
            'name' => 'Fabric Softener',
            'fee' => 30.00,
            'is_active' => true,
            'service_id' => $expressWash->id,
        ]);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $expressWash->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'add_ons' => [$expressAntibacterial->id, $expressFabricSoftener->id],
        ]);

        $response->assertCreated();

        $order = Order::with('addOnServices')->findOrFail($response->json('data.id'));

        $this->assertSame(60.0, (float) $order->add_on_total);
        $this->assertSame(320.0, (float) $order->total_price);
        $this->assertCount(2, $order->addOnServices);

        $invalidResponse = $this->postJson('/api/orders', [
            'service_id' => $expressWash->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'add_ons' => [$globalAntibacterial->id],
        ]);

        $invalidResponse
            ->assertStatus(422)
            ->assertJsonValidationErrors('add_ons');
    }

    public function test_basic_dry_cleaning_add_on_services_endpoint_uses_service_specific_catalog(): void
    {
        $basicDryCleaning = Service::factory()->create([
            'name' => 'Basic Dry Cleaning',
            'description' => 'Professional chemical-based cleaning for special and delicate fabrics like suits, gowns, barong, and formal wear.',
            'price_per_kg' => 150.00,
        ]);

        AddOnService::factory()->create([
            'name' => 'Stain Pre-Treatment',
            'fee' => 20.00,
            'is_active' => true,
            'service_id' => null,
        ]);

        AddOnService::factory()->create([
            'name' => 'Stain Pre-Treatment',
            'description' => "Targeted treatment for tough stains like oil, ink, and food that basic dry cleaning alone can't fully remove.",
            'fee' => 50.00,
            'is_active' => true,
            'service_id' => $basicDryCleaning->id,
        ]);

        AddOnService::factory()->create([
            'name' => 'Garment Bag',
            'description' => 'Clean garments are placed in a protective bag to keep them fresh and dust-free after dry cleaning.',
            'fee' => 25.00,
            'is_active' => true,
            'service_id' => $basicDryCleaning->id,
        ]);

        $response = $this->getJson('/api/add-on-services?service_id='.$basicDryCleaning->id);

        $response->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonFragment([
                'name' => 'Stain Pre-Treatment',
                'fee' => 50.0,
            ])
            ->assertJsonFragment([
                'name' => 'Garment Bag',
                'fee' => 25.0,
            ]);

        $basicDryCleaningCatalog = collect($response->json('data', []));

        $this->assertNull($basicDryCleaningCatalog->first(
            fn (array $item) =>
                ($item['name'] ?? null) === 'Stain Pre-Treatment'
                && (float) ($item['fee'] ?? 0) === 20.0
        ));
    }

    public function test_basic_dry_cleaning_order_uses_service_specific_add_on_fees(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $basicDryCleaning = Service::factory()->create([
            'name' => 'Basic Dry Cleaning',
            'description' => 'Professional chemical-based cleaning for special and delicate fabrics like suits, gowns, barong, and formal wear.',
            'price_per_kg' => 150.00,
        ]);

        $globalStainPreTreatment = AddOnService::factory()->create([
            'name' => 'Stain Pre-Treatment',
            'fee' => 20.00,
            'is_active' => true,
            'service_id' => null,
        ]);

        $basicDryCleaningStainPreTreatment = AddOnService::factory()->create([
            'name' => 'Stain Pre-Treatment',
            'fee' => 50.00,
            'is_active' => true,
            'service_id' => $basicDryCleaning->id,
        ]);

        $basicDryCleaningGarmentBag = AddOnService::factory()->create([
            'name' => 'Garment Bag',
            'fee' => 25.00,
            'is_active' => true,
            'service_id' => $basicDryCleaning->id,
        ]);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $basicDryCleaning->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'add_ons' => [$basicDryCleaningStainPreTreatment->id, $basicDryCleaningGarmentBag->id],
        ]);

        $response->assertCreated();

        $order = Order::with('addOnServices')->findOrFail($response->json('data.id'));

        $this->assertSame(75.0, (float) $order->add_on_total);
        $this->assertSame(285.0, (float) $order->total_price);
        $this->assertCount(2, $order->addOnServices);

        $invalidResponse = $this->postJson('/api/orders', [
            'service_id' => $basicDryCleaning->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'add_ons' => [$globalStainPreTreatment->id],
        ]);

        $invalidResponse
            ->assertStatus(422)
            ->assertJsonValidationErrors('add_ons');
    }

    public function test_inactive_add_on_service_is_rejected_during_order_creation(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $service = Service::factory()->create([
            'name' => 'Wash-Dry-Fold',
            'price_per_kg' => 24.00,
        ]);

        $inactiveAddOn = AddOnService::factory()->create([
            'name' => 'Inactive Add-On',
            'fee' => 30.00,
            'is_active' => false,
        ]);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/orders', [
            'service_id' => $service->id,
            'weight_kg' => 8,
            'pickup_address' => '123 Main Street',
            'add_ons' => [$inactiveAddOn->id],
        ]);

        $response
            ->assertStatus(422)
            ->assertJsonValidationErrors('add_ons');

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseCount('order_add_on_services', 0);
    }
}
