<?php

namespace App\Services;

use App\Models\BookingSummary;
use App\Models\Order;
use Illuminate\Support\Carbon;

class BookingSummaryService
{
    /**
     * Update booking summary for a specific date or today
     */
    public static function updateSummary(?Carbon $date = null): void
    {
        $date = $date ?? Carbon::today();
        
        $summary = self::calculateSummary($date);
        
        BookingSummary::updateOrCreate(
            ['summary_date' => $date],
            $summary
        );
    }

    /**
     * Calculate booking statistics for a given date
     */
    private static function calculateSummary(Carbon $date): array
    {
        $startOfDay = $date->copy()->startOfDay();
        $endOfDay = $date->copy()->endOfDay();

        // Query orders for the given date
        $query = Order::whereBetween('created_at', [$startOfDay, $endOfDay]);
        
        $totalBookings = $query->count();
        $pendingBookings = $query->clone()->where('status', 'pending')->count();
        $ongoingBookings = $query->clone()->whereIn('status', ['in_progress', 'ongoing', 'processing'])->count();
        $readyBookings = $query->clone()->where('status', 'ready')->count();
        $completedBookings = $query->clone()->where('status', 'completed')->count();
        $cancelledBookings = $query->clone()->where('status', 'cancelled')->count();
        
        // Calculate total revenue (from completed orders only)
        $totalRevenue = $query->clone()
            ->where('status', 'completed')
            ->sum('total_price') ?? 0;
        
        // Calculate total weight
        $totalWeight = $query->clone()->sum('weight_kg') ?? 0;

        return [
            'total_bookings' => $totalBookings,
            'requested_bookings' => $pendingBookings,
            'accepted_bookings' => $ongoingBookings + $readyBookings,
            'declined_bookings' => 0, // If you have a 'declined' status, add it here
            'completed_bookings' => $completedBookings,
            'cancelled_bookings' => $cancelledBookings,
            'total_revenue' => $totalRevenue,
            'total_weight_kg' => $totalWeight,
        ];
    }

    /**
     * Recalculate all summaries from a start date to today
     */
    public static function recalculateAllSummaries(Carbon $fromDate): void
    {
        $currentDate = $fromDate->copy();
        $today = Carbon::today();

        while ($currentDate->lte($today)) {
            self::updateSummary($currentDate);
            $currentDate->addDay();
        }
    }
}
