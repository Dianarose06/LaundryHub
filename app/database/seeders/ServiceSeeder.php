<?php

namespace Database\Seeders;

use App\Models\Service;
use Illuminate\Database\Seeder;

class ServiceSeeder extends Seeder
{
    public function run(): void
    {
        $services = [
            ['name' => 'Wash & Dry', 'description' => 'Full wash and dry service', 'price_per_kg' => 65.00, 'category' => 'Basic'],
            ['name' => 'Dry Cleaning', 'description' => 'Dry cleaning for delicate wear', 'price_per_kg' => 180.00, 'category' => 'Specialty'],
            ['name' => 'Wash & Iron', 'description' => 'Clothes washed and ironed', 'price_per_kg' => 85.00, 'category' => 'Premium'],
            ['name' => 'Beddings', 'description' => 'Deep wash for blankets and linens', 'price_per_kg' => 90.00, 'category' => 'Basic'],
            ['name' => 'Express Wash', 'description' => 'Same-day rush wash service', 'price_per_kg' => 120.00, 'category' => 'Express'],
            ['name' => 'Shoe Cleaning', 'description' => 'Professional cleaning for all shoe types', 'price_per_kg' => 150.00, 'category' => 'Specialty'],
            ['name' => 'Soft Wash', 'description' => 'Gentle wash for delicates and baby clothes', 'price_per_kg' => 75.00, 'category' => 'Premium'],
            ['name' => 'Sportswear', 'description' => 'Wash for jerseys, gym clothes, and uniforms', 'price_per_kg' => 70.00, 'category' => 'Basic'],
        ];
        foreach ($services as $service) {
            Service::firstOrCreate(['name' => $service['name']], $service);
        }
    }
}