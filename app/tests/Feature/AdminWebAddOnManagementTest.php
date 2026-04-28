<?php

namespace Tests\Feature;

use App\Models\AddOnService;
use App\Models\Service;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminWebAddOnManagementTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->withoutMiddleware(\Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class);
    }

    public function test_admin_can_create_update_and_delete_add_on_service_from_web(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'email_verified_at' => now(),
        ]);

        $service = Service::factory()->create([
            'name' => 'Web Managed Service',
        ]);

        $createResponse = $this->actingAs($admin)->post('/admin/add-on-services', [
            'service_id' => $service->id,
            'name' => 'VIP Fragrance',
            'description' => 'Premium fragrance boost.',
            'fee' => 35.50,
            'is_active' => 1,
        ]);

        $createResponse->assertRedirect(route('admin.dashboard', ['status' => 'all']));

        $this->assertDatabaseHas('add_on_services', [
            'name' => 'VIP Fragrance',
            'service_id' => $service->id,
            'fee' => 35.50,
            'is_active' => true,
        ]);

        $addOn = AddOnService::where('name', 'VIP Fragrance')->firstOrFail();

        $updateResponse = $this->actingAs($admin)->put('/admin/add-on-services/'.$addOn->id, [
            'service_id' => null,
            'name' => 'VIP Fragrance Updated',
            'description' => 'Now global.',
            'fee' => 40,
            'is_active' => 0,
        ]);

        $updateResponse->assertRedirect(route('admin.dashboard', ['status' => 'all']));

        $this->assertDatabaseHas('add_on_services', [
            'id' => $addOn->id,
            'service_id' => null,
            'name' => 'VIP Fragrance Updated',
            'fee' => 40.00,
            'is_active' => false,
        ]);

        $deleteResponse = $this->actingAs($admin)->delete('/admin/add-on-services/'.$addOn->id);

        $deleteResponse->assertRedirect(route('admin.dashboard', ['status' => 'all']));

        $this->assertDatabaseMissing('add_on_services', [
            'id' => $addOn->id,
        ]);
    }

    public function test_non_admin_cannot_manage_web_add_on_services(): void
    {
        $customer = User::factory()->create([
            'role' => 'customer',
            'email_verified_at' => now(),
        ]);

        $response = $this->actingAs($customer)->post('/admin/add-on-services', [
            'name' => 'Blocked Add-on',
            'fee' => 20,
        ]);

        $response->assertForbidden();
    }

    public function test_guest_is_redirected_when_managing_web_add_on_services(): void
    {
        $response = $this->post('/admin/add-on-services', [
            'name' => 'Blocked Add-on',
            'fee' => 20,
        ]);

        $response->assertRedirect('/login');
    }
}
