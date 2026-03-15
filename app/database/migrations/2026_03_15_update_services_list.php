<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Remove the 4 services to be deleted
        DB::table('services')->whereIn('id', [2, 6, 13, 17])->delete();

        // Add the new Wash-Dry-Fold service
        DB::table('services')->insert([
            'name' => 'Wash-Dry-Fold',
            'description' => 'Complete laundry service including washing, drying, and folding clothes',
            'price_per_kg' => 80.00,
            'category' => 'standard',
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function down(): void
    {
        // Delete the new service
        DB::table('services')->where('name', 'Wash-Dry-Fold')->delete();

        // Restore the removed services
        DB::table('services')->insert([
            ['id' => 2, 'name' => 'Wash & Iron', 'description' => 'Clothes washed and ironed', 'price_per_kg' => 85.00, 'category' => 'premium', 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
            ['id' => 6, 'name' => 'Wash & Dry', 'description' => 'Full wash and dry service', 'price_per_kg' => 65.00, 'category' => 'standard', 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
            ['id' => 13, 'name' => 'Shoe Cleaning', 'description' => 'Professional cleaning for all shoe types', 'price_per_kg' => 150.00, 'category' => 'specialty', 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
            ['id' => 17, 'name' => 'Sportswear', 'description' => 'Wash for jerseys, gym clothes, and uniforms', 'price_per_kg' => 70.00, 'category' => 'standard', 'is_active' => true, 'created_at' => now(), 'updated_at' => now()],
        ]);
    }
};
