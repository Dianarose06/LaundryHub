<?php

namespace Tests\Unit;

use App\Models\BookingSummary;
use App\Models\Order;
use App\Services\BookingSummaryService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class BookingSummaryServiceTest extends TestCase
{
    use RefreshDatabase;

    // ── 1. Summary is created for today if none exists ────────────────────────

    public function test_summary_is_created_for_today(): void
    {
        $today = Carbon::today();

        BookingSummaryService::updateSummary($today);

        $summary = BookingSummary::whereDate('summary_date', $today->toDateString())->first();

        $this->assertNotNull($summary);
    }

    // ── 2. Total bookings count is correct ────────────────────────────────────

    public function test_total_bookings_count_is_correct(): void
    {
        $today = Carbon::today();

        Order::factory()->count(3)->create([
            'created_at' => $today,
            'status'     => 'pending',
        ]);

        $summary = BookingSummary::whereDate('summary_date', $today->toDateString())->first();

        $this->assertSame(3, (int) $summary->total_bookings);
    }

    // ── 3. Pending bookings are counted as requested ──────────────────────────

    public function test_pending_bookings_counted_as_requested(): void
    {
        $today = Carbon::today();

        Order::factory()->count(2)->create([
            'created_at' => $today,
            'status'     => 'pending',
        ]);

        $summary = BookingSummary::whereDate('summary_date', $today->toDateString())->first();

        $this->assertSame(2, (int) $summary->requested_bookings);
    }

    // ── 4. Ongoing and ready bookings are counted as accepted ─────────────────

    public function test_ongoing_and_ready_counted_as_accepted(): void
    {
        $today = Carbon::today();

        Order::factory()->create(['created_at' => $today, 'status' => 'ongoing']);
        Order::factory()->create(['created_at' => $today, 'status' => 'ready']);

        $summary = BookingSummary::whereDate('summary_date', $today->toDateString())->first();

        $this->assertSame(2, (int) $summary->accepted_bookings);
    }

    // ── 5. Only completed orders contribute to revenue ────────────────────────

    public function test_only_completed_orders_counted_in_revenue(): void
    {
        $today = Carbon::today();

        Order::factory()->create([
            'created_at'  => $today,
            'status'      => 'completed',
            'total_price' => 150.00,
        ]);

        Order::factory()->create([
            'created_at'  => $today,
            'status'      => 'pending',
            'total_price' => 200.00, // should NOT count
        ]);

        $summary = BookingSummary::whereDate('summary_date', $today->toDateString())->first();

        $this->assertSame(150.00, (float) $summary->total_revenue);
    }

    // ── 6. Total weight includes all orders regardless of status ─────────────

    public function test_total_weight_includes_all_orders(): void
    {
        $today = Carbon::today();

        Order::factory()->create(['created_at' => $today, 'status' => 'pending',   'weight_kg' => 3]);
        Order::factory()->create(['created_at' => $today, 'status' => 'completed', 'weight_kg' => 5]);

        $summary = BookingSummary::whereDate('summary_date', $today->toDateString())->first();

        $this->assertSame(8, (int) $summary->total_weight_kg);
    }

    // ── 7. Cancelled bookings are counted correctly ───────────────────────────

    public function test_cancelled_bookings_are_counted(): void
    {
        $today = Carbon::today();

        Order::factory()->count(2)->create([
            'created_at' => $today,
            'status'     => 'cancelled',
        ]);

        $summary = BookingSummary::whereDate('summary_date', $today->toDateString())->first();

        $this->assertSame(2, (int) $summary->cancelled_bookings);
    }

    // ── 8. Orders from other dates are NOT counted ────────────────────────────

    public function test_orders_from_other_dates_are_excluded(): void
    {
        $today     = Carbon::today();
        $yesterday = Carbon::yesterday();

        Order::factory()->count(3)->create([
            'created_at' => $yesterday,
            'status'     => 'pending',
        ]);

        BookingSummaryService::updateSummary($today);

        $summary = BookingSummary::whereDate('summary_date', $today->toDateString())->first();

        $this->assertSame(0, (int) $summary->total_bookings);
    }

    // ── 9. Summary is updated (not duplicated) when called twice ─────────────

    public function test_summary_is_updated_not_duplicated(): void
    {
        $today = Carbon::today();

        Order::factory()->create(['created_at' => $today, 'status' => 'pending']);
        Order::factory()->create(['created_at' => $today, 'status' => 'pending']);

        $count = BookingSummary::whereDate('summary_date', $today->toDateString())->count();

        $this->assertSame(1, $count); // still 1 row, not 2
    }

    // ── 10. recalculateAllSummaries creates a summary for each day ────────────

    public function test_recalculate_creates_summary_for_each_day(): void
    {
        $from = Carbon::today()->subDays(2);

        BookingSummaryService::recalculateAllSummaries($from);

        // 2 days ago + yesterday + today = 3
        $this->assertSame(3, BookingSummary::count());
    }

    // ── 11. Zero revenue when no completed orders exist ───────────────────────

    public function test_zero_revenue_when_no_completed_orders(): void
    {
        $today = Carbon::today();

        Order::factory()->count(2)->create([
            'created_at'  => $today,
            'status'      => 'pending',
            'total_price' => 500.00,
        ]);

        $summary = BookingSummary::whereDate('summary_date', $today->toDateString())->first();

        $this->assertSame(0.0, (float) $summary->total_revenue);
    }

    // ── 12. Empty day produces all-zero summary ───────────────────────────────

    public function test_empty_day_produces_zero_summary(): void
    {
        $today = Carbon::today();

        BookingSummaryService::updateSummary($today);

        $summary = BookingSummary::whereDate('summary_date', $today->toDateString())->first();

        $this->assertNotNull($summary);
        $this->assertSame(0, (int) $summary->total_bookings);
        $this->assertSame(0.0, (float) $summary->total_revenue);
        $this->assertSame(0, (int) $summary->total_weight_kg);
    }
}