<?php

namespace Database\Seeders;

use App\Models\AddOnService;
use App\Models\Order;
use App\Models\Service;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class CustomerOrderSeeder extends Seeder
{
    private const USER_COUNT = 300;

    private const DEFAULT_PASSWORD = 'Password123';

    public function run(): void
    {
        $seededEmailDomain = 'seed.laundryhub.ph';

        $existingSeededUsers = User::query()
            ->where('email', 'like', "%@{$seededEmailDomain}")
            ->count();

        if ($existingSeededUsers >= self::USER_COUNT) {
            $this->command?->info('CustomerOrderSeeder skipped: 300 seeded users already exist.');
            return;
        }

        $services = Service::query()->where('is_active', true)->get();
        if ($services->isEmpty()) {
            $this->command?->warn('CustomerOrderSeeder skipped: no active services found.');
            return;
        }

        $globalAddOns = AddOnService::query()
            ->where('is_active', true)
            ->whereNull('service_id')
            ->get();

        $faker = fake('en_PH');
        $faker->unique(true);

        $statuses = ['pending', 'ongoing', 'completed'];
        $barangays = [
            'Abucay', 'Anibong', 'Aslum', 'Bagacay', 'San Jose',
            'Sagkahan', 'Downtown', 'Picas', 'San Isidro', 'Nula-Tula',
        ];

        for ($i = 1; $i <= self::USER_COUNT; $i++) {
            $firstName = $faker->unique()->firstName();
            $lastName = $faker->unique()->lastName();
            $email = Str::lower("{$firstName}.{$lastName}.{$i}@{$seededEmailDomain}");
            $phone = '09' . str_pad((string) (100000000 + $i), 9, '0', STR_PAD_LEFT);

            $user = User::updateOrCreate(
                ['email' => $email],
                [
                    'name' => "{$firstName} {$lastName}",
                    'password' => Hash::make(self::DEFAULT_PASSWORD),
                    'phone' => $phone,
                    'role' => 'customer',
                    'email_verified_at' => now(),
                    'verification_code' => '000000',
                    'remember_token' => Str::random(60),
                    'city' => 'Tacloban City',
                    'country' => 'Philippines',
                    'preferred_language' => 'en',
                    'notifications_enabled' => true,
                    'loyalty_points' => random_int(0, 300),
                ]
            );

            if ($user->orders()->exists()) {
                continue;
            }

            $orderCount = random_int(1, 5);

            for ($j = 0; $j < $orderCount; $j++) {
                $service = $services->random();
                $serviceAddOns = AddOnService::query()
                    ->where('is_active', true)
                    ->where('service_id', $service->id)
                    ->get();

                $availableAddOns = $serviceAddOns->isNotEmpty() ? $serviceAddOns : $globalAddOns;
                $status = $statuses[array_rand($statuses)];
                $weightKg = (float) number_format(mt_rand(20, 120) / 10, 2, '.', '');
                $pickupFee = (float) random_int(0, 40);
                $deliveryFee = (float) random_int(0, 60);
                $basePrice = round($weightKg * (float) $service->price_per_kg, 2);
                $orderDate = Carbon::now()->subDays(random_int(1, 120))->setTime(random_int(7, 18), [0, 15, 30, 45][array_rand([0, 1, 2, 3])]);
                $deliveryDateTime = (clone $orderDate)->addDays(random_int(1, 3));
                $deliveryType = random_int(0, 1) ? 'pickup' : 'delivery';

                $selectedAddOns = collect();
                if ($availableAddOns->isNotEmpty()) {
                    $selectedAddOns = $availableAddOns->random(random_int(0, min(3, $availableAddOns->count())));
                    if (! $selectedAddOns instanceof \Illuminate\Support\Collection) {
                        $selectedAddOns = collect([$selectedAddOns]);
                    }
                }

                $addOnTotal = round((float) $selectedAddOns->sum(fn ($addOn) => (float) $addOn->fee), 2);
                $totalPrice = round($basePrice + $addOnTotal + $pickupFee + $deliveryFee, 2);

                $order = Order::create([
                    'user_id' => $user->id,
                    'service_id' => $service->id,
                    'weight_kg' => $weightKg,
                    'total_price' => $totalPrice,
                    'add_on_total' => $addOnTotal,
                    'pickup_fee' => $pickupFee,
                    'delivery_fee' => $deliveryFee,
                    'fee_zone' => ['Zone A', 'Zone B', 'Zone C'][array_rand(['Zone A', 'Zone B', 'Zone C'])],
                    'status' => $status,
                    'completed_at' => $status === 'completed' ? (clone $deliveryDateTime) : null,
                    'pickup_address' => $faker->streetAddress() . ', Brgy. ' . $barangays[array_rand($barangays)] . ', Tacloban City',
                    'pickup_city' => 'Tacloban City',
                    'pickup_barangay' => $barangays[array_rand($barangays)],
                    'pickup_date' => $orderDate->toDateString(),
                    'pickup_time' => $orderDate->format('H:i:s'),
                    'delivery_date' => $deliveryDateTime->toDateString(),
                    'delivery_time' => $deliveryDateTime->format('H:i:s'),
                    'delivery_type' => $deliveryType,
                    'type' => $deliveryType,
                    'notes' => $faker->optional(0.55)->sentence(),
                ]);

                if ($selectedAddOns->isNotEmpty()) {
                    $pivotData = $selectedAddOns->mapWithKeys(
                        fn ($addOn) => [$addOn->id => ['fee' => $addOn->fee]]
                    )->all();
                    $order->addOnServices()->attach($pivotData);
                }
            }
        }

        $this->command?->info('CustomerOrderSeeder finished: seeded/updated 300 Filipino customer accounts with realistic orders.');
    }
}
