<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Update service prices to store the full 8kg package price instead of per-kg
        DB::table('services')->where('name', 'Express Wash')->update(['price_per_kg' => 200]);
        DB::table('services')->where('name', 'Soft Wash')->update(['price_per_kg' => 75]);
        DB::table('services')->where('name', 'Beddings')->update(['price_per_kg' => 180]);
        DB::table('services')->where('name', 'Wash-Dry-Fold')->update(['price_per_kg' => 150]);
        DB::table('services')->where('name', 'Dry Cleaning')->update(['price_per_kg' => 150]);
    }

    public function down(): void
    {
        // Revert to per-kg pricing
        DB::table('services')->where('name', 'Express Wash')->update(['price_per_kg' => 25.00]);
        DB::table('services')->where('name', 'Soft Wash')->update(['price_per_kg' => 9.38]);
        DB::table('services')->where('name', 'Beddings')->update(['price_per_kg' => 22.50]);
        DB::table('services')->where('name', 'Wash-Dry-Fold')->update(['price_per_kg' => 18.75]);
        DB::table('services')->where('name', 'Dry Cleaning')->update(['price_per_kg' => 18.75]);
    }
};
