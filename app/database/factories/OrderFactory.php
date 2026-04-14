<?php

namespace Database\Factories;

use App\Models\Order;
use App\Models\Service;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class OrderFactory extends Factory
{
    protected $model = Order::class;

    public function definition(): array
    {
        return [
            'user_id'        => User::factory(),
            'service_id'     => Service::factory(),
            'weight_kg'      => $this->faker->randomFloat(2, 1, 20),
            'total_price'    => $this->faker->randomFloat(2, 50, 500),
            'status'         => $this->faker->randomElement(['pending', 'ongoing', 'ready', 'completed', 'cancelled']),
            'pickup_address' => $this->faker->address(),
            'pickup_date'    => $this->faker->dateTimeBetween('now', '+7 days'),
            'pickup_time'    => $this->faker->time('H:i'),
            'delivery_date'  => $this->faker->dateTimeBetween('+1 day', '+14 days'),
            'delivery_time'  => $this->faker->time('H:i'),
            'delivery_type'  => $this->faker->randomElement(['pickup', 'delivery']),
            'notes'          => $this->faker->optional()->sentence(),
            'admin_notes'    => null,
        ];
    }
}