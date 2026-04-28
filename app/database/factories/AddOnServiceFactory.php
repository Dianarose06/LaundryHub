<?php

namespace Database\Factories;

use App\Models\AddOnService;
use Illuminate\Database\Eloquent\Factories\Factory;

class AddOnServiceFactory extends Factory
{
    protected $model = AddOnService::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->randomElement([
                'Antibacterial Boost',
                'Fabric Softener',
                'Stain Removal Treatment',
                'Ironing',
            ]),
            'description' => $this->faker->sentence(),
            'fee' => $this->faker->randomFloat(2, 15, 50),
            'is_active' => true,
        ];
    }
}
