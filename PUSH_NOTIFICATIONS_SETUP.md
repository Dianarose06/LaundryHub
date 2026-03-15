# Push Notifications Setup Guide - Sprint 3

## Overview
This implements Firebase Cloud Messaging (FCM) for push notifications to customers when their laundry orders status changes.

## Architecture

### Backend (Laravel)
- **NotificationService**: Handles FCM API calls and database logging
- **DeviceTokenController**: Manages device token registration/removal
- **Notification Model**: Stores notification history for audit trail

### Frontend (Flutter)
- **NotificationService**: Initializes FCM, handles message reception
- **firebase_messaging**: Plugin for FCM integration
- **firebase_core**: Firebase initialization

### Data Flow
```
1. Customer login → Flutter registers device token with backend
2. Admin updates order status → AdminController calls NotificationService
3. NotificationService sends FCM notification → Customer receives push
4. Notification logged in database for history
```

## Setup Instructions

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a new project" or select existing project
3. Enable "Cloud Messaging" in the project
4. Download credentials:
   - For Android: Download `google-services.json`
   - For iOS: Download `GoogleService-Info.plist`

### Step 2: Get FCM Server Key

1. In Firebase Console, go to **Project Settings** → **Cloud Messaging** tab
2. Copy the **Server Key** (labeled as "Server API Key")
3. Add to Laravel `.env`:
   ```
   FIREBASE_SERVER_KEY=YOUR_SERVER_KEY_HERE
   ```

### Step 3: Configure Flutter Firebase Options

1. Update `mobile/lib/firebase_options.dart`:
   ```dart
   static const FirebaseOptions android = FirebaseOptions(
     apiKey: 'YOUR_ANDROID_API_KEY',
     appId: 'YOUR_ANDROID_APP_ID',
     messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
     projectId: 'YOUR_PROJECT_ID',
   );

   static const FirebaseOptions ios = FirebaseOptions(
     apiKey: 'YOUR_IOS_API_KEY',
     appId: 'YOUR_IOS_APP_ID',
     messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
     projectId: 'YOUR_PROJECT_ID',
   );
   ```
   
   Get these values from Firebase Console → Project Settings

### Step 4: Add Google Services Files

#### Android
1. Copy `google-services.json` to `mobile/android/app/`
2. Ensure `android/build.gradle` has:
   ```gradle
   classpath 'com.google.gms:google-services:4.3.15'
   ```
3. Ensure `android/app/build.gradle` has:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### iOS
1. Open `mobile/ios/Runner.xcworkspace` in Xcode
2. Add `GoogleService-Info.plist` to the Runner project
3. Ensure target membership is set to Runner

### Step 5: Update Dependencies

Flutter:
```bash
cd mobile
flutter pub get
```

Laravel (if not already installed):
```bash
composer require laravel/framework
composer require illuminate/support
```

### Step 6: Run Migrations

```bash
# In Docker
docker-compose exec -T app php artisan migrate --force

# Or locally
php artisan migrate
```

This creates:
- `device_tokens` table: Stores device tokens
- `app_notifications` table: Tracks notification history

## API Endpoints

### Register Device Token
```
POST /api/device-tokens
Headers: Authorization: Bearer {token}

Body:
{
  "token": "FCM_TOKEN_HERE",
  "device_type": "android|ios",
  "device_name": "Device name"
}

Response: 201 Created
{
  "success": true,
  "message": "Device token registered successfully",
  "data": {...}
}
```

### Get Notifications
```
GET /api/notifications
Headers: Authorization: Bearer {token}

Response: 200 OK
{
  "data": [
    {
      "id": 1,
      "title": "Order Status Update",
      "message": "Your Express Wash order is ready for pickup!",
      "type": "order_status",
      "order_id": 5,
      "is_read": false,
      "created_at": "2026-03-15T10:30:00Z"
    }
  ]
}
```

### Mark Notification as Read
```
PATCH /api/notifications/{notificationId}/read
Headers: Authorization: Bearer {token}

Response: 200 OK
{
  "success": true,
  "message": "Notification marked as read"
}
```

### Unregister Device Token
```
DELETE /api/device-tokens
Headers: Authorization: Bearer {token}

Body:
{
  "token": "FCM_TOKEN_HERE"
}

Response: 200 OK
{
  "success": true,
  "message": "Device token removed successfully"
}
```

## Notification Types & Messages

When admin updates order status:

| Status | Message Example |
|--------|-----------------|
| `ongoing` | "⚡ Express Wash is now being processed" |
| `ready` | "✅ Your Express Wash is ready for pickup/delivery" |
| `completed` | "🎉 Your Express Wash order is completed!" |
| `cancelled` | "❌ Your Express Wash order has been cancelled" |

## Testing Notifications

### Manual Testing via FCM Console
1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter message title and body
4. Select target as "Single device"
5. Paste a device token and send

### Testing in App Flow
1. Login as customer → device token auto-registers
2. Login as admin in another device/session
3. Go to Manage Bookings → Find any Ongoing order
4. Click status chips and mark as "Complete"
5. Customer should receive notification instantly

### View Notification History
- Customer can view all notifications via `GET /api/notifications`
- Each notification is logged with full metadata
- Notifications marked as read/unread

## Troubleshooting

### No Notifications Received
1. Verify Firebase Server Key in .env: `php artisan tinker` → `config('services.firebase.server_key')`
2. Check device token is registered: Query `device_tokens` table
3. Check FCM response in Laravel logs: `storage/logs/laravel-*.log`
4. Verify Firebase project is active and Cloud Messaging enabled

### Token Registration Fails
1. Check authentication token is valid
2. Verify device is connected to internet
3. Check `notification_service.dart` logs for FCM errors

### Firebase Options Issues
1. Verify all credentials in `firebase_options.dart` are correct
2. For Android: Check `google-services.json` is in correct location
3. For iOS: Check `GoogleService-Info.plist` is added to Xcode project

## Production Considerations

1. **Token Refresh**: FCM tokens can refresh; implement token refresh listeners
2. **Token Cleanup**: Remove tokens for uninstalled apps periodically
3. **Rate Limiting**: Avoid sending too many notifications (Firebase has per-device limits)
4. **Message Format**: Keep messages short for better mobile display
5. **Silent Notifications**: For background task implementation
6. **Segmentation**: Can extend to send different messages based on user preferences

## Security Notes

- Never hardcode FCM credentials in app
- Use environment variables for server key
- Validate user owns device token before sending
- Log all notification sends for audit trail
- Use HTTPS for all API calls

## Next Steps

1. Test notification delivery on physical devices
2. Implement notification preferences (enable/disable by type)
3. Add notification sound/vibration customization
4. Implement notification click handling (navigate to order details)
5. Add admin notification system for new bookings
