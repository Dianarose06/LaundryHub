<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Service;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    private function getServiceEmoji(string $serviceName): string
    {
        return match(strtolower($serviceName)) {
            'express wash' => '⚡',
            'soft wash' => '🫧',
            'beddings' => '🛏️',
            'wash-dry-fold' => '👕',
            'dry cleaning' => '🧼',
            default => '🧺',
        };
    }

    public function index(Request $request)
    {
        $orders = $request->user()
            ->orders()
            ->with('service')
            ->latest()
            ->paginate(20)
            ->map(fn ($order) => [
                'id' => $order->id,
                'service_type' => $order->service?->name ?? 'Unknown Service',
                'service_emoji' => $this->getServiceEmoji($order->service?->name ?? ''),
                'status' => $order->status,
                'weight_kg' => $order->weight_kg,
                'total_price' => $order->total_price,
                'pickup_address' => $order->pickup_address,
                'pickup_date' => $order->pickup_date,
                'pickup_time' => $order->pickup_time,
                'delivery_date' => $order->delivery_date,
                'delivery_time' => $order->delivery_time,
                'delivery_type' => $order->delivery_type ?? 'pickup',
                'special_instructions' => $order->notes,
                'created_at' => $order->created_at,
                'updated_at' => $order->updated_at,
            ]);

        return response()->json(['data' => $orders]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'service_id'     => 'required|exists:services,id',
            'weight_kg'      => 'required|numeric|min:0.1|max:500',
            'pickup_address' => 'required|string|max:500',
            'pickup_date'    => 'nullable|date',
            'pickup_time'    => 'nullable|date_format:H:i',
            'delivery_date'  => 'nullable|date',
            'delivery_time'  => 'nullable|date_format:H:i',
            'delivery_type'  => 'nullable|in:pickup,delivery',
            'notes'          => 'nullable|string|max:1000',
        ]);

        $service = Service::findOrFail($validated['service_id']);

        $order = Order::create([
            'user_id'        => $request->user()->id,
            'service_id'     => $service->id,
            'weight_kg'      => $validated['weight_kg'],
            'total_price'    => round($service->price_per_kg * $validated['weight_kg'], 2),
            'status'         => 'pending',
            'pickup_address' => $validated['pickup_address'],
            'pickup_date'    => $validated['pickup_date'] ?? null,
            'pickup_time'    => $validated['pickup_time'] ?? null,
            'delivery_date'  => $validated['delivery_date'] ?? null,
            'delivery_time'  => $validated['delivery_time'] ?? null,
            'delivery_type'  => $validated['delivery_type'] ?? 'pickup',
            'notes'          => $validated['notes'] ?? null,
        ]);

        $order->load('service');

        return response()->json(['data' => $order], 201);
    }

    public function show(Request $request, Order $order)
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $order->load('service');

        return response()->json(['data' => $order]);
    }

    public function cancel(Request $request, Order $order)
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        if (! in_array($order->status, ['pending', 'processing', 'ready'])) {
            return response()->json([
                'message' => 'Orders that are completed or already cancelled cannot be cancelled.',
            ], 422);
        }

        $order->update(['status' => 'cancelled']);

        return response()->json(['data' => $order]);
    }
}
