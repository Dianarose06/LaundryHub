<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $this->call(ServiceSeeder::class);

        // Admin account
        User::updateOrCreate(
            ['email' => 'admin@laundryhub.com'],
            [
                'name'              => 'Admin',
                'password'          => bcrypt('admin1234'),
                'role'              => 'admin',
                'phone'             => '09000000000',
                'email_verified_at' => now(),
                'verification_code' => '000000',
                'remember_token'    => \Illuminate\Support\Str::random(60),
            ]
        );

        // Test customer account
        User::updateOrCreate(
            ['email' => 'test@example.com'],
            [
                'name'              => 'Test User',
                'password'          => bcrypt('password'),
                'role'              => 'customer',
                'phone'             => '09111111111',
                'email_verified_at' => now(),
                'verification_code' => '000000',
                'remember_token'    => \Illuminate\Support\Str::random(60),
            ]
        );
    }
}
