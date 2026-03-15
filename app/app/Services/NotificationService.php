<?php

namespace App\Services;

use App\Models\DeviceToken;
use App\Models\Notification;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    private string $fcmApiUrl = 'https://fcm.googleapis.com/fcm/send';
    private string $fcmServerKey;

    public function __construct()
    {
        $this->fcmServerKey = config('services.firebase.server_key') ?? env('FIREBASE_SERVER_KEY');
    }

    /**
     * Send push notification to a user
     */
    public function sendToUser(
        int $userId,
        string $title,
        string $message,
        string $type = 'general',
        ?int $orderId = null,
        array $data = []
    ): void {
        // Get active device tokens for user
        $tokens = DeviceToken::where('user_id', $userId)
            ->where('is_active', true)
            ->pluck('token')
            ->toArray();

        if (empty($tokens)) {
            Log::warning("No device tokens found for user {$userId}");
            return;
        }

        // Store notification in database
        $notification = Notification::create([
            'user_id' => $userId,
            'order_id' => $orderId,
            'title' => $title,
            'message' => $message,
            'type' => $type,
            'data' => $data,
        ]);

        // Send to all devices
        foreach ($tokens as $token) {
            $this->sendPushNotification(
                $token,
                $title,
                $message,
                array_merge($data, ['notification_id' => $notification->id])
            );
        }
    }

    /**
     * Send push notification to multiple users
     */
    public function sendToUsers(
        array $userIds,
        string $title,
        string $message,
        string $type = 'general',
        ?int $orderId = null,
        array $data = []
    ): void {
        foreach ($userIds as $userId) {
            $this->sendToUser($userId, $title, $message, $type, $orderId, $data);
        }
    }

    /**
     * Send FCM push notification
     */
    private function sendPushNotification(string $token, string $title, string $message, array $data = []): void
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'key=' . $this->fcmServerKey,
                'Content-Type' => 'application/json',
            ])->post($this->fcmApiUrl, [
                'to' => $token,
                'notification' => [
                    'title' => $title,
                    'body' => $message,
                    'sound' => 'default',
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ],
                'data' => $data,
                'priority' => 'high',
            ]);

            if (!$response->successful()) {
                Log::error("FCM send failed for token {$token}", ['response' => $response->body()]);
                // Deactivate token if it fails repeatedly
                if ($response->status() == 401) {
                    DeviceToken::where('token', $token)->update(['is_active' => false]);
                }
            }
        } catch (\Exception $e) {
            Log::error("Error sending FCM notification: " . $e->getMessage());
        }
    }
}
