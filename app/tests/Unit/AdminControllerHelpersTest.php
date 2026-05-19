<?php

namespace Tests\Unit;

use App\Http\Controllers\Api\AdminController;
use App\Models\Order;
use Tests\TestCase;

class AdminControllerHelpersTest extends TestCase
{
    private function callPrivate(AdminController $controller, string $method, array $args = [])
    {
        $reflection = new \ReflectionMethod($controller, $method);
        $reflection->setAccessible(true);

        return $reflection->invokeArgs($controller, $args);
    }

    public function test_calculate_loyalty_points_minimum_is_one(): void
    {
        $controller = new AdminController();
        $order = new Order(['total_price' => 0]);

        $points = $this->callPrivate($controller, 'calculateLoyaltyPointsForOrder', [$order]);

        $this->assertSame(1, $points);
    }

    public function test_calculate_loyalty_points_scales_by_100_php(): void
    {
        $controller = new AdminController();
        $order = new Order(['total_price' => 250]);

        $points = $this->callPrivate($controller, 'calculateLoyaltyPointsForOrder', [$order]);

        $this->assertSame(2, $points);
    }

    public function test_format_display_name_handles_middle_initial_and_trim(): void
    {
        $controller = new AdminController();

        $formatted = $this->callPrivate($controller, 'formatDisplayName', ['  Jane  ', '  Doe ', ' q ']);

        $this->assertSame('Doe, Jane Q.', $formatted);
    }

    public function test_get_service_emoji_matches_known_categories(): void
    {
        $controller = new AdminController();

        $wash = $this->callPrivate($controller, 'getServiceEmoji', ['Wash-Dry-Fold']);
        $washAlt = $this->callPrivate($controller, 'getServiceEmoji', ["Wash\u{2013}Dry\u{2013}Fold"]);
        $dryCleaning = $this->callPrivate($controller, 'getServiceEmoji', ['Dry Cleaning Deluxe']);
        $beddings = $this->callPrivate($controller, 'getServiceEmoji', ['Beddings']);
        $express = $this->callPrivate($controller, 'getServiceEmoji', ['Express Wash']);
        $soft = $this->callPrivate($controller, 'getServiceEmoji', ['Soft Wash']);
        $default = $this->callPrivate($controller, 'getServiceEmoji', ['Unknown Service']);

        $this->assertSame("\u{1F9FA}", $wash);
        $this->assertSame("\u{1F9FA}", $washAlt);
        $this->assertSame("\u{2728}", $dryCleaning);
        $this->assertSame("\u{1F6CF}\u{FE0F}", $beddings);
        $this->assertSame("\u{26A1}", $express);
        $this->assertSame("\u{1F338}", $soft);
        $this->assertSame("\u{1F9FA}", $default);
    }

    public function test_percentage_change_handles_edge_cases(): void
    {
        $controller = new AdminController();

        $increase = $this->callPrivate($controller, 'percentageChange', [150.0, 100.0]);
        $noPrevious = $this->callPrivate($controller, 'percentageChange', [50.0, 0.0]);
        $noChange = $this->callPrivate($controller, 'percentageChange', [0.0, 0.0]);

        $this->assertSame(50, $increase);
        $this->assertSame(100, $noPrevious);
        $this->assertNull($noChange);
    }
}
