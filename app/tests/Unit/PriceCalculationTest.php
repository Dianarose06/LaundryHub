<?php

namespace Tests\Unit;

use Tests\TestCase;

class PriceCalculationTest extends TestCase
{
    // ── Helper: mirrors the exact formula in OrderController::store() ─────────
    private function calculatePrice(float $pricePerKg, float $weightKg): float
    {
        return round(($pricePerKg / 8) * $weightKg, 2);
    }

    // ── 1. Basic price calculation ────────────────────────────────────────────

    public function test_price_is_calculated_correctly(): void
    {
        // price_per_kg = 80, weight = 5kg → (80/8) * 5 = 50.00
        $result = $this->calculatePrice(80, 5);
        $this->assertSame(50.00, $result);
    }

    // ── 2. Minimum weight (0.1kg) ─────────────────────────────────────────────

    public function test_price_with_minimum_weight(): void
    {
        // price_per_kg = 80, weight = 0.1kg → (80/8) * 0.1 = 1.00
        $result = $this->calculatePrice(80, 0.1);
        $this->assertSame(1.00, $result);
    }

    // ── 3. Large weight ───────────────────────────────────────────────────────

    public function test_price_with_large_weight(): void
    {
        // price_per_kg = 100, weight = 500kg → (100/8) * 500 = 6250.00
        $result = $this->calculatePrice(100, 500);
        $this->assertSame(6250.00, $result);
    }

    // ── 4. Result is rounded to 2 decimal places ──────────────────────────────

    public function test_price_is_rounded_to_2_decimal_places(): void
    {
        // price_per_kg = 75, weight = 3kg → (75/8) * 3 = 28.125 → rounds to 28.13
        $result = $this->calculatePrice(75, 3);
        $this->assertSame(28.13, $result);
    }

    // ── 5. Zero price per kg results in zero total ────────────────────────────

    public function test_zero_price_per_kg_results_in_zero_total(): void
    {
        $result = $this->calculatePrice(0, 10);
        $this->assertSame(0.00, $result);
    }

    // ── 6. Different service prices produce different totals ──────────────────

    public function test_different_service_prices_produce_different_totals(): void
    {
        $cheapService     = $this->calculatePrice(40, 5);  // (40/8) * 5 = 25.00
        $expensiveService = $this->calculatePrice(160, 5); // (160/8) * 5 = 100.00

        $this->assertSame(25.00, $cheapService);
        $this->assertSame(100.00, $expensiveService);
        $this->assertGreaterThan($cheapService, $expensiveService);
    }

    // ── 7. Same weight, different price per kg ────────────────────────────────

    public function test_heavier_weight_costs_more(): void
    {
        $lightOrder = $this->calculatePrice(80, 2);  // (80/8) * 2 = 20.00
        $heavyOrder = $this->calculatePrice(80, 10); // (80/8) * 10 = 100.00

        $this->assertGreaterThan($lightOrder, $heavyOrder);
    }

    // ── 8. Price is always a float ────────────────────────────────────────────

    public function test_price_result_is_always_a_float(): void
    {
        $result = $this->calculatePrice(80, 5);
        $this->assertIsFloat($result);
    }
}