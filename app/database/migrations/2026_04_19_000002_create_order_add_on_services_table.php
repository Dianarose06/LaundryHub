<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('order_add_on_services', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->cascadeOnDelete();
            $table->foreignId('add_on_service_id')->constrained()->cascadeOnDelete();
            $table->decimal('fee', 8, 2);
            $table->timestamps();

            $table->unique(['order_id', 'add_on_service_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('order_add_on_services');
    }
};
