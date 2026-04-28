<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;
use Tests\TestCase;

class AdminWebAccessTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_is_redirected_to_web_login_for_admin_route(): void
    {
        $response = $this->get('/admin');

        $response->assertRedirect('/login');
    }

    public function test_non_admin_user_is_forbidden_from_admin_route(): void
    {
        $user = User::factory()->create([
            'role' => 'customer',
            'email_verified_at' => now(),
        ]);

        $response = $this->actingAs($user)->get('/admin');

        $response->assertForbidden();
    }

    public function test_admin_user_can_open_admin_route(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'email_verified_at' => now(),
        ]);

        $response = $this->actingAs($admin)->get('/admin');

        $response->assertOk();
    }

    public function test_bridge_login_auto_authenticates_admin_and_redirects_to_dashboard(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'email_verified_at' => now(),
        ]);

        $token = Str::random(64);
        Cache::put("admin_bridge_login:{$token}", $admin->id, now()->addMinutes(2));

        $response = $this->get(route('admin.bridge-login', ['token' => $token]));

        $response->assertRedirect(route('admin.dashboard'));
        $this->assertAuthenticatedAs($admin);
    }

    public function test_bridge_login_with_invalid_token_redirects_back_to_login(): void
    {
        $response = $this->get(route('admin.bridge-login', ['token' => 'invalid-token']));

        $response->assertRedirect(route('login'));
        $response->assertSessionHasErrors('email');
        $this->assertGuest();
    }
}
