<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminApiAccessTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_login_response_includes_redirect_url(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'email_verified_at' => now(),
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $admin->email,
            'password' => 'password',
        ]);

        $response->assertOk()
            ->assertJsonPath('role', 'admin');

        $redirectUrl = (string) $response->json('redirect_url');
        $parts = parse_url($redirectUrl);
        parse_str((string) ($parts['query'] ?? ''), $params);

        $this->assertSame('/admin/bridge-login', $parts['path'] ?? null);
        $this->assertNotEmpty($params['token'] ?? null);
    }

    public function test_non_admin_login_response_is_mapped_to_user_role(): void
    {
        $customer = User::factory()->create([
            'role' => 'customer',
            'email_verified_at' => now(),
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $customer->email,
            'password' => 'password',
        ]);

        $response->assertOk()
            ->assertJsonPath('role', 'user')
            ->assertJsonPath('user.role', 'user');
    }

    public function test_non_admin_cannot_access_admin_routes(): void
    {
        $customer = User::factory()->create([
            'role' => 'customer',
            'email_verified_at' => now(),
        ]);

        Sanctum::actingAs($customer);

        $response = $this->getJson('/api/admin/stats');

        $response->assertForbidden()
            ->assertJsonPath('message', 'Forbidden: Admin access required.');
    }

    public function test_admin_can_access_admin_routes(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'email_verified_at' => now(),
        ]);

        Sanctum::actingAs($admin);

        $response = $this->getJson('/api/admin/stats');

        $response->assertOk();
    }
}
