<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\User;
use App\Notifications\AdminNewOrderPlaced;
use App\Notifications\OrderConfirmation;
use App\Notifications\OrderRefundInitiated;
use App\Notifications\OrderStatusUpdated;
use App\Models\Service;
use App\Models\AddOnService;
use App\Models\Barangay;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class OrderController extends Controller
{
    private const TACLOBAN_CITY = 'Tacloban City, Leyte';
    private const DEFAULT_PICKUP_FEE = 30.00;
    private const DEFAULT_DELIVERY_FEE = 30.00;

    private function logisticsFeeExplanation(): array
    {
        return [
            'delivery_can_be_higher' => true,
            'pickup_applies_when' => 'delivery_type is pickup',
            'delivery_applies_when' => 'always',
            'reason' => 'Delivery includes route planning, customer handoff coordination, and possible wait time.',
        ];
    }

    private function responseMeta(): array
    {
        return [
            'logistics_fee_explanation' => $this->logisticsFeeExplanation(),
        ];
    }

    private function calculateLogisticsFees(string $deliveryType, ?Barangay $barangay = null): array
    {
        $basePickupFee = $barangay
            ? (float) $barangay->pickup_fee
            : self::DEFAULT_PICKUP_FEE;

        $baseDeliveryFee = $barangay
            ? (float) $barangay->delivery_fee
            : self::DEFAULT_DELIVERY_FEE;

        $pickupFee = $deliveryType === 'pickup' ? $basePickupFee : 0.0;
        $deliveryFee = $baseDeliveryFee;

        $feeZone = $barangay
            ? 'Zone '.((int) $barangay->zone)
            : 'Default';

        return [
            'pickup_fee' => round($pickupFee, 2),
            'delivery_fee' => round($deliveryFee, 2),
            'fee_zone' => $feeZone,
            'pickup_city' => $barangay?->city ?? self::TACLOBAN_CITY,
            'pickup_barangay' => $barangay?->name,
        ];
    }

    private function isEmailNotificationEnabled(User $user): bool
    {
        return !empty($user->email) && $user->notifications_enabled !== false;
    }

    private function sendAdminNewOrderEmail(Order $order): void
    {
        $order->loadMissing(['user', 'service']);

        $admins = User::where('role', 'admin')
            ->whereNotNull('email')
            ->where('notifications_enabled', true)
            ->get();

        foreach ($admins as $admin) {
            try {
                $admin->notify(new AdminNewOrderPlaced($order));
            } catch (\Throwable $exception) {
                Log::warning('Unable to send admin new-order email.', [
                    'order_id' => $order->id,
                    'admin_id' => $admin->id,
                    'error' => $exception->getMessage(),
                ]);
            }
        }
    }

    private function sendOrderConfirmationEmail(Order $order): void
    {
        $order->loadMissing(['user', 'service']);

        $user = $order->user;

        if (!$user || !$this->isEmailNotificationEnabled($user)) {
            return;
        }

        try {
            $user->notify(new OrderConfirmation($order));
        } catch (\Throwable $exception) {
            Log::warning('Unable to send order confirmation email.', [
                'order_id' => $order->id,
                'user_id' => $user->id,
                'error' => $exception->getMessage(),
            ]);
        }
    }

    private function sendOrderStatusEmail(Order $order, string $previousStatus, string $nextStatus): void
    {
        $order->loadMissing(['user', 'service']);

        $user = $order->user;

        if (!$user || !$this->isEmailNotificationEnabled($user)) {
            return;
        }

        try {
            $user->notify(new OrderStatusUpdated($order, $previousStatus, $nextStatus));
        } catch (\Throwable $exception) {
            Log::warning('Unable to send order status email.', [
                'order_id' => $order->id,
                'user_id' => $user->id,
                'from_status' => $previousStatus,
                'to_status' => $nextStatus,
                'error' => $exception->getMessage(),
            ]);
        }
    }

    private function sendRefundInitiatedEmail(Order $order, string $reason): void
    {
        $order->loadMissing(['user', 'service']);

        $user = $order->user;

        if (!$user || !$this->isEmailNotificationEnabled($user)) {
            return;
        }

        try {
            $user->notify(new OrderRefundInitiated($order, $reason));
        } catch (\Throwable $exception) {
            Log::warning('Unable to send refund-initiated email.', [
                'order_id' => $order->id,
                'user_id' => $user->id,
                'error' => $exception->getMessage(),
            ]);
        }
    }

    private function getServiceEmoji(string $serviceName): string
    {
        $normalized = strtolower(trim($serviceName));
        
        if (str_contains($normalized, 'wash-dry-fold') || str_contains($normalized, 'wash–dry–fold')) {
            return '🧺';
        } elseif (str_contains($normalized, 'dry cleaning')) {
            return '✨';
        } elseif (str_contains($normalized, 'beddings')) {
            return '🛏️';
        } elseif (str_contains($normalized, 'express wash')) {
            return '⚡';
        } elseif (str_contains($normalized, 'soft wash')) {
            return '🌸';
        }
        
        return '🧺'; // Default
    }

    public function index(Request $request)
    {
        $orders = $request->user()
            ->orders()
            ->with(['service', 'addOnServices', 'pickupBarangay'])
            ->latest()
            ->paginate(20)
            ->map(function ($order) {
                $deliveryType = $order->delivery_type ?? 'pickup';
                $computedFees = $this->calculateLogisticsFees($deliveryType, $order->pickupBarangay);

                $pickupFee = $order->pickup_fee !== null
                    ? (float) $order->pickup_fee
                    : (float) $computedFees['pickup_fee'];

                $deliveryFee = $order->delivery_fee !== null
                    ? (float) $order->delivery_fee
                    : (float) $computedFees['delivery_fee'];

                return [
                    'id' => $order->id,
                    'service_type' => $order->service?->name ?? 'Unknown Service',
                    'service_emoji' => $this->getServiceEmoji($order->service?->name ?? ''),
                    'status' => $order->status,
                    'weight_kg' => (float)$order->weight_kg,
                    'total_price' => (float)$order->total_price,
                    'add_on_total' => (float)$order->add_on_total,
                    'pickup_fee' => $pickupFee,
                    'delivery_fee' => $deliveryFee,
                    'fee_zone' => $order->fee_zone ?? $computedFees['fee_zone'],
                    'add_ons' => $order->addOnServices->map(fn ($addOn) => [
                        'id' => $addOn->id,
                        'name' => $addOn->name,
                        'fee' => (float)($addOn->pivot->fee ?? $addOn->fee),
                    ])->values(),
                    'pickup_address' => $order->pickup_address,
                    'pickup_city' => $order->pickup_city ?? $computedFees['pickup_city'],
                    'pickup_barangay_id' => $order->pickup_barangay_id,
                    'pickup_barangay' => $order->pickup_barangay ?? $computedFees['pickup_barangay'],
                    'pickup_date' => $order->pickup_date,
                    'pickup_time' => $order->pickup_time,
                    'delivery_date' => $order->delivery_date,
                    'delivery_time' => $order->delivery_time,
                    'delivery_type' => $deliveryType,
                    'payment_method' => 'cod',
                    'special_instructions' => $order->notes,
                    'created_at' => $order->created_at,
                    'updated_at' => $order->updated_at,
                ];
            });

        return response()->json([
            'data' => $orders,
            'meta' => $this->responseMeta(),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'service_id'     => 'required|exists:services,id',
            'weight_kg'      => 'required|numeric|min:0.1|max:500',
            'pickup_address' => 'required|string|max:500',
            'pickup_barangay_id' => 'nullable|integer|exists:barangays,id',
            'pickup_city' => 'nullable|string|max:100',
            'pickup_date'    => 'nullable|date',
            'pickup_time'    => 'nullable|date_format:H:i',
            'delivery_date'  => 'nullable|date',
            'delivery_time'  => 'nullable|date_format:H:i',
            'delivery_type'  => 'nullable|in:pickup,delivery',
            'payment_method' => 'nullable|in:cod',
            'notes'          => 'nullable|string|max:1000',
            'add_ons'        => 'nullable|array',
            'add_ons.*'      => 'integer|distinct|exists:add_on_services,id',
        ]);

        $requestedCity = trim((string) ($validated['pickup_city'] ?? ''));
        if ($requestedCity !== '' && strcasecmp($requestedCity, self::TACLOBAN_CITY) !== 0) {
            return response()->json([
                'message' => 'Only Tacloban City, Leyte addresses are supported right now.',
                'errors' => [
                    'pickup_city' => ['Only Tacloban City, Leyte addresses are supported right now.'],
                ],
            ], 422);
        }

        $pickupBarangay = null;
        if (!empty($validated['pickup_barangay_id'])) {
            $pickupBarangay = Barangay::query()
                ->active()
                ->where('city', self::TACLOBAN_CITY)
                ->whereKey($validated['pickup_barangay_id'])
                ->first();

            if (!$pickupBarangay) {
                return response()->json([
                    'message' => 'Selected barangay is unavailable for Tacloban City.',
                    'errors' => [
                        'pickup_barangay_id' => ['Selected barangay is unavailable for Tacloban City.'],
                    ],
                ], 422);
            }
        }

        $service = Service::findOrFail($validated['service_id']);
        $deliveryType = $validated['delivery_type'] ?? 'pickup';
        $fees = $this->calculateLogisticsFees($deliveryType, $pickupBarangay);
        $basePrice = round(($service->price_per_kg / 8) * $validated['weight_kg'], 2);

        $addOnIds = $validated['add_ons'] ?? [];
        $addOnServices = collect();
        if (!empty($addOnIds)) {
            $serviceHasSpecificAddOns = AddOnService::where('service_id', $service->id)
                ->where('is_active', true)
                ->exists();

            $addOnQuery = AddOnService::whereIn('id', $addOnIds)
                ->where('is_active', true);

            if ($serviceHasSpecificAddOns) {
                $addOnQuery->where('service_id', $service->id);
            } else {
                $addOnQuery->whereNull('service_id');
            }

            $addOnServices = $addOnQuery->get();

            if ($addOnServices->count() !== count($addOnIds)) {
                return response()->json([
                    'message' => 'One or more selected add-ons are unavailable.',
                    'errors' => [
                        'add_ons' => ['One or more selected add-ons are unavailable.'],
                    ],
                ], 422);
            }
        }

        $addOnTotal = round((float) $addOnServices->sum('fee'), 2);
        $totalPrice = round(
            $basePrice
            + $addOnTotal
            + (float) $fees['pickup_fee']
            + (float) $fees['delivery_fee'],
            2
        );

        $order = Order::create([
            'user_id'        => $request->user()->id,
            'service_id'     => $service->id,
            'weight_kg'      => $validated['weight_kg'],
            'total_price'    => $totalPrice,
            'add_on_total'   => $addOnTotal,
            'status'         => 'pending',
            'pickup_address' => $validated['pickup_address'],
            'pickup_barangay_id' => $pickupBarangay?->id,
            'pickup_city' => $fees['pickup_city'],
            'pickup_barangay' => $fees['pickup_barangay'],
            'pickup_date'    => $validated['pickup_date'] ?? null,
            'pickup_time'    => $validated['pickup_time'] ?? null,
            'delivery_date'  => $validated['delivery_date'] ?? null,
            'delivery_time'  => $validated['delivery_time'] ?? null,
            'delivery_type'  => $deliveryType,
            'pickup_fee'     => (float) $fees['pickup_fee'],
            'delivery_fee'   => (float) $fees['delivery_fee'],
            'fee_zone'       => $fees['fee_zone'],
            'notes'          => $validated['notes'] ?? null,
        ]);

        if ($addOnServices->isNotEmpty()) {
            $order->addOnServices()->attach(
                $addOnServices->mapWithKeys(fn (AddOnService $addOn) => [
                    $addOn->id => ['fee' => $addOn->fee],
                ])->all()
            );
        }

        $order->load(['service', 'addOnServices', 'pickupBarangay']);

        $this->sendOrderConfirmationEmail($order);
        $this->sendAdminNewOrderEmail($order);

        return response()->json([
            'data' => $order,
            'meta' => $this->responseMeta(),
        ], 201);
    }

    public function show(Request $request, Order $order)
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $order->load(['service', 'addOnServices', 'pickupBarangay']);

        return response()->json([
            'data' => $order,
            'meta' => $this->responseMeta(),
        ]);
    }

    public function cancel(Request $request, Order $order)
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        if (! in_array($order->status, ['pending', 'ongoing', 'ready'])) {
            return response()->json([
                'message' => 'Orders that are completed or already cancelled cannot be cancelled.',
            ], 422);
        }

        $previousStatus = $order->status;
        $order->update(['status' => 'cancelled']);
        $this->sendOrderStatusEmail($order, $previousStatus, 'cancelled');
        $this->sendRefundInitiatedEmail($order, 'Order was cancelled by customer.');

        return response()->json([
            'data' => $order,
            'meta' => $this->responseMeta(),
        ]);
    }
}
