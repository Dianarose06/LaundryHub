<?php

namespace Database\Factories;

use App\Models\Service;
use Illuminate\Database\Eloquent\Factories\Factory;

class ServiceFactory extends Factory
{
    protected $model = Service::class;

    public function definition(): array
    {
        return [
            'name'        => $this->faker->randomElement([
                'Wash & Fold', 'Dry Cleaning', 'Iron Only', 'Wash & Iron', 'Express Laundry'
            ]),
            'description' => $this->faker->sentence(),
            'price_per_kg'=> $this->faker->randomFloat(2, 20, 100),
            'category'    => $this->faker->randomElement(['standard', 'premium', 'express']),
            'image_url'   => null,
            'is_active'   => true,
        ];
    }
}