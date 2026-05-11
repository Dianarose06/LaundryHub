<?php

namespace Tests\Feature;

use App\Models\AddOnService;
use App\Models\Service;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AddOnServiceAdminManagementTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_list_add_on_services_for_management(): void
    {
        $service = Service::factory()->create(['name' => 'Management Service']);

        AddOnService::factory()->create([
            'service_id' => $service->id,
            'name' => 'Inactive Admin Add-on',
            'is_active' => false,
        ]);

        $admin = User::factory()->create([
            'role' => 'admin',
            'email_verified_at' => now(),
        ]);

        Sanctum::actingAs($admin);

        $response = $this->getJson('/api/admin/add-on-services');

        $response->assertOk()
            ->assertJsonFragment([
                'name' => 'Inactive Admin Add-on',
                'service_name' => 'Management Service',
                'is_active' => false,
            ]);
    }

    public function test_admin_can_create_add_on_service(): void
    {
        $service = Service::factory()->create(['name' => 'Create Target Service']);

        $admin = User::factory()->create([
            'role' => 'admin',
            'email_verified_at' => now(),
        ]);

        Sanctum::actingAs($admin);

        $response = $this->postJson('/api/admin/add-on-services', [
            'service_id' => $service->id,
            'name' => 'Premium Fragrance',
            'description' => 'Adds premium scent.',
            'fee' => 45,
            'is_active' => true,
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.name', 'Premium Fragrance')
            ->assertJsonPath('data.service_id', $service->id)
            ->assertJsonPath('data.service_name', 'Create Target Service')
            ->assertJsonPath('data.fee', 45);

        $this->assertDatabaseHas('add_on_services', [
            'name' => 'Premium Fragrance',
            'service_id' => $service->id,
            'fee' => 45.00,
            'is_active' => true,
        ]);
    }

    public function test_admin_can_update_add_on_service(): void
    {
        $sourceService = Service::factory()->create(['name' => 'Source Service']);
        $targetService = Service::factory()->create(['name' => 'Target Service']);

        $addOn = AddOnService::factory()->create([
            'service_id' => $sourceService->id,
            'name' => 'Editable Add-on',
            'fee' => 20,
            'is_active' => true,
        ]);

        $admin = User::factory()->create([
            'role' => 'admin',
            'email_verified_at' => now(),
        ]);

        Sanctum::actingAs($admin);

        $response = $this->putJson('/api/admin/add-on-services/'.$addOn->id, [
            'service_id' => $targetService->id,
            'fee' => 55,
            'is_active' => false,
            'description' => 'Updated by admin.',
        ]);

        $response->assertOk()
            ->assertJsonPath('data.id', $addOn->id)
            ->assertJsonPath('data.service_id', $targetService->id)
            ->assertJsonPath('data.service_name', 'Target Service')
            ->assertJsonPath('data.fee', 55)
            ->assertJsonPath('data.is_active', false);

        $this->assertDatabaseHas('add_on_services', [
            'id' => $addOn->id,
            'service_id' => $targetService->id,
            'fee' => 55.00,
            'is_active' => false,
            'description' => 'Updated by admin.',
        ]);
    }

    public function test_admin_can_delete_add_on_service(): void
    {
        $addOn = AddOnService::factory()->create([
            'name' => 'Delete Me',
        ]);

        $admin = User::factory()->create([
            'role' => 'admin',
            'email_verified_at' => now(),
        ]);

        Sanctum::actingAs($admin);

        $response = $this->deleteJson('/api/admin/add-on-services/'.$addOn->id);

        $response->assertOk()
            ->assertJsonPath('message', 'Add-on service deleted successfully');

        $this->assertDatabaseMissing('add_on_services', [
            'id' => $addOn->id,
        ]);
    }

    public function test_non_admin_cannot_manage_add_on_services(): void
    {
        $customer = User::factory()->create([
            'role' => 'customer',
            'email_verified_at' => now(),
        ]);

        Sanctum::actingAs($customer);

        $response = $this->postJson('/api/admin/add-on-services', [
            'name' => 'Blocked Add-on',
            'fee' => 25,
        ]);

        $response->assertForbidden()
            ->assertJsonPath('message', 'Forbidden: Admin access required.');
    }

    public function test_unauthenticated_user_cannot_manage_add_on_services(): void
    {
        $response = $this->postJson('/api/admin/add-on-services', [
            'name' => 'Blocked Add-on',
            'fee' => 25,
        ]);

        $response->assertUnauthorized();
    }
}
