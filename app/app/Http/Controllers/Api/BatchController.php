<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\Order;
use App\Models\Service;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BatchController extends Controller
{
    /**
     * Customer home payload in one request.
     */
    public function home(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $ordersLimit = $this->sanitizeLimit((int) $request->query('orders_limit', 20), 50);
        $notificationsLimit = $this->sanitizeLimit((int) $request->query('notifications_limit', 5), 20);

        $includeServices = filter_var(
            $request->query('include_services', true),
            FILTER_VALIDATE_BOOLEAN,
            FILTER_NULL_ON_FAILURE,
        );
        $includeServices = $includeServices ?? true;

        $orders = $user->orders()
            ->with('service')
            ->latest()
            ->take($ordersLimit)
            ->get()
            ->map(fn (Order $order) => $this->transformOrder($order))
            ->values();

        $activeOrdersCount = $user->orders()
            ->whereIn('status', ['pending', 'ongoing', 'ready', 'in_progress', 'processing'])
            ->count();

        $recentNotifications = Notification::where('user_id', $user->id)
            ->latest()
            ->take($notificationsLimit)
            ->get()
            ->map(fn (Notification $notification) => $this->transformNotification($notification))
            ->values();

        $unreadNotifications = Notification::where('user_id', $user->id)
            ->where('is_read', false)
            ->count();

        $services = $includeServices
            ? Service::where('is_active', true)->orderBy('id')->get()->values()
            : [];

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $this->transformUser($user),
                'orders' => $orders,
                'services' => $services,
                'notification_summary' => [
                    'unread_count' => $unreadNotifications,
                    'recent' => $recentNotifications,
                ],
                'meta' => [
                    'orders_count' => $user->orders()->count(),
                    'active_orders_count' => $activeOrdersCount,
                ],
            ],
        ]);
    }

    /**
     * Customer profile payload in one request.
     */
    public function profile(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $recentOrdersLimit = $this->sanitizeLimit((int) $request->query('recent_orders_limit', 5), 20);
        $notificationsLimit = $this->sanitizeLimit((int) $request->query('notifications_limit', 5), 20);

        $recentOrders = $user->orders()
            ->with('service')
            ->latest()
            ->take($recentOrdersLimit)
            ->get()
            ->map(fn (Order $order) => $this->transformOrder($order))
            ->values();

        $notificationsBase = Notification::where('user_id', $user->id);

        $recentNotifications = (clone $notificationsBase)
            ->latest()
            ->take($notificationsLimit)
            ->get()
            ->map(fn (Notification $notification) => $this->transformNotification($notification))
            ->values();

        return response()->json([
            'success' => true,
            'data' => [
                'profile' => $this->transformUser($user),
                'completion_status' => $this->calculateCompletionStatus($user),
                'recent_orders' => $recentOrders,
                'notification_summary' => [
                    'unread_count' => (clone $notificationsBase)->where('is_read', false)->count(),
                    'total_count' => (clone $notificationsBase)->count(),
                    'recent' => $recentNotifications,
                ],
            ],
        ]);
    }

    private function sanitizeLimit(int $value, int $max): int
    {
        if ($value < 1) {
            return 1;
        }

        return min($value, $max);
    }

    private function transformUser(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'role' => $user->role,
            'profile_picture_url' => $user->profile_picture_url,
            'bio' => $user->bio,
            'address' => $user->address,
            'city' => $user->city,
            'zip_code' => $user->zip_code,
            'country' => $user->country,
            'date_of_birth' => $user->date_of_birth,
            'gender' => $user->gender,
            'preferred_language' => $user->preferred_language,
            'notifications_enabled' => $user->notifications_enabled,
            'loyalty_points' => (int) ($user->loyalty_points ?? 0),
            'email_verified_at' => $user->email_verified_at,
            'profile_completed_at' => $user->profile_completed_at,
            'created_at' => $user->created_at,
        ];
    }

    private function calculateCompletionStatus(User $user): array
    {
        $profileFields = [
            'name' => !empty($user->name),
            'email' => !empty($user->email),
            'phone' => !empty($user->phone),
            'address' => !empty($user->address),
            'city' => !empty($user->city),
            'country' => !empty($user->country),
            'profile_picture_url' => !empty($user->profile_picture_url),
            'date_of_birth' => !empty($user->date_of_birth),
            'gender' => !empty($user->gender),
        ];

        $completedFields = array_sum($profileFields);
        $totalFields = count($profileFields);

        return [
            'completed_percentage' => (int) round(($completedFields / max($totalFields, 1)) * 100),
            'total_fields' => $totalFields,
            'completed_fields' => $completedFields,
            'fields' => $profileFields,
            'is_profile_complete' => $user->profile_completed_at !== null,
        ];
    }

    private function transformOrder(Order $order): array
    {
        return [
            'id' => $order->id,
            'service_type' => $order->service?->name ?? 'Unknown Service',
            'status' => $order->status,
            'weight_kg' => (float) $order->weight_kg,
            'total_price' => (float) $order->total_price,
            'pickup_address' => $order->pickup_address,
            'pickup_date' => $order->pickup_date,
            'pickup_time' => $order->pickup_time,
            'delivery_date' => $order->delivery_date,
            'delivery_time' => $order->delivery_time,
            'delivery_type' => $order->delivery_type ?? 'pickup',
            'special_instructions' => $order->notes,
            'created_at' => $order->created_at,
            'updated_at' => $order->updated_at,
        ];
    }

    private function transformNotification(Notification $notification): array
    {
        return [
            'id' => $notification->id,
            'order_id' => $notification->order_id,
            'title' => $notification->title,
            'message' => $notification->message,
            'type' => $notification->type,
            'data' => $notification->data,
            'is_read' => $notification->is_read,
            'read_at' => $notification->read_at,
            'created_at' => $notification->created_at,
        ];
    }
}
