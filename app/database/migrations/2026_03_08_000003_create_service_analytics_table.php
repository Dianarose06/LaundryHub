<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('service_analytics', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_id')->constrained()->cascadeOnDelete();
            $table->date('analytics_date');
            $table->integer('order_count')->default(0);
            $table->decimal('total_revenue', 10, 2)->default(0);
            $table->decimal('total_weight_kg', 10, 2)->default(0);
            $table->timestamps();
            
            $table->unique(['service_id', 'analytics_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('service_analytics');
    }
};
