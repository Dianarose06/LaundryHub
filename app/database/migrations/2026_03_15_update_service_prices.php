<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Update service prices (converted from 8kg unit to per-kg)
        DB::table('services')->where('name', 'Express Wash')->update(['price_per_kg' => 25.00]);
        DB::table('services')->where('name', 'Soft Wash')->update(['price_per_kg' => 9.375]);
        DB::table('services')->where('name', 'Beddings')->update(['price_per_kg' => 22.50]);
        DB::table('services')->where('name', 'Wash-Dry-Fold')->update(['price_per_kg' => 18.75]);
        DB::table('services')->where('name', 'Dry Cleaning')->update(['price_per_kg' => 18.75]);
    }

    public function down(): void
    {
        // Revert to original prices
        DB::table('services')->where('name', 'Express Wash')->update(['price_per_kg' => 120.00]);
        DB::table('services')->where('name', 'Soft Wash')->update(['price_per_kg' => 75.00]);
        DB::table('services')->where('name', 'Beddings')->update(['price_per_kg' => 90.00]);
        DB::table('services')->where('name', 'Wash-Dry-Fold')->update(['price_per_kg' => 80.00]);
        DB::table('services')->where('name', 'Dry Cleaning')->update(['price_per_kg' => 180.00]);
    }
};
