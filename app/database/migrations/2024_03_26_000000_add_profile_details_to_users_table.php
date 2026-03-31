<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Add profile-related columns
            $table->string('profile_picture_url')->nullable()->after('phone');
            $table->text('bio')->nullable()->after('profile_picture_url');
            $table->string('address')->nullable()->after('bio');
            $table->string('city')->nullable()->after('address');
            $table->string('zip_code')->nullable()->after('city');
            $table->string('country')->nullable()->after('zip_code');
            $table->date('date_of_birth')->nullable()->after('country');
            $table->enum('gender', ['male', 'female', 'other'])->nullable()->after('date_of_birth');
            $table->string('preferred_language')->default('en')->after('gender');
            $table->boolean('notifications_enabled')->default(true)->after('preferred_language');
            $table->timestamp('last_login_at')->nullable()->after('notifications_enabled');
            $table->timestamp('profile_completed_at')->nullable()->after('last_login_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'profile_picture_url',
                'bio',
                'address',
                'city',
                'zip_code',
                'country',
                'date_of_birth',
                'gender',
                'preferred_language',
                'notifications_enabled',
                'last_login_at',
                'profile_completed_at',
            ]);
        });
    }
};
