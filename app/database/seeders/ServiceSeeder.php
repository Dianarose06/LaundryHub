<?php

namespace Database\Seeders;

use App\Models\Service;
use Illuminate\Database\Seeder;

class ServiceSeeder extends Seeder
{
    public function run(): void
    {
        // Sprint 2 - Final 5 services with 8kg package pricing
        $services = [
            ['name' => 'Express Wash', 'description' => 'Same-day rush wash service', 'price_per_kg' => 200, 'category' => 'Express', 'is_active' => true],
            ['name' => 'Soft Wash', 'description' => 'Gentle wash for delicates and baby clothes', 'price_per_kg' => 75, 'category' => 'Premium', 'is_active' => true],
            ['name' => 'Beddings', 'description' => 'Deep wash for blankets and linens', 'price_per_kg' => 180, 'category' => 'Basic', 'is_active' => true],
            ['name' => 'Wash-Dry-Fold', 'description' => 'Complete laundry service including washing, drying, and folding clothes', 'price_per_kg' => 150, 'category' => 'Standard', 'is_active' => true],
            ['name' => 'Dry Cleaning', 'description' => 'Dry cleaning for delicate wear', 'price_per_kg' => 150, 'category' => 'Specialty', 'is_active' => true],
        ];
        foreach ($services as $service) {
            Service::firstOrCreate(['name' => $service['name']], $service);
        }
    }
}