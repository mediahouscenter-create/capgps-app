# Privacy Policy for CapGPS (TrackCapGPS)

**Last Updated:** August 28, 2026  
**Package Name:** `com.trackcapgps.app`

Welcome to **CapGPS**. We are committed to respecting and protecting your privacy. This Privacy Policy outlines how our mobile application handles data from vehicle GPS hardware trackers and user account interaction.

---

## 1. How Data is Collected & Handled

### A. Vehicle Tracking Data (From Hardware GPS Trackers)
The primary function of CapGPS is to display tracking data provided by **hardware GPS tracking devices installed on vehicles**.
- **Vehicle Location & Telemetry**: GPS coordinates, speed, heading, altitude, ignition status, idle duration, and distance traveled.
- **Vehicle Alerts**: Geofence alerts, overspeeding notifications, and ignition status updates.
- **Data Source**: This data originates directly from vehicle hardware trackers connected to the CapGPS server, **not** from your personal phone's background tracking.

### B. Mobile App User Data (From Your Mobile Device)
When using the mobile application on your device:
- **User Account Credentials**: We store your username/email and encrypted session tokens (`user_api_hash`) locally on your device to maintain your logged-in state.
- **User Phone Location (Optional)**: If you grant location permission on your phone, the app accesses your device's location **only in the foreground** to display your position relative to your vehicles on the map ("My Location" feature). We do **not** track or collect your personal mobile phone location in the background.
- **Push Notification Tokens**: We collect Firebase Cloud Messaging (FCM) tokens to deliver urgent real-time alerts (e.g., geofence breach, overspeeding, engine status) to your notification tray.
- **App Preferences**: Selected language (Arabic, English, French), notification toggles, and map display preferences stored locally.

---

## 2. How We Use Your Information

We use information strictly to provide fleet management and vehicle security services:
- Displaying real-time vehicle positions on Google Maps.
- Generating trip history playbacks, parking duration logs, and speed analytics.
- Sending real-time push notification alerts configured for your vehicles.
- Assisting in vehicle security and fleet monitoring.

We **do not** sell, rent, or trade your personal or vehicle tracking data to third-party advertisers or marketers.

---

## 3. Data Sharing & Third-Party Services

We only share data with essential third-party service providers required for core app functions:
- **Google Maps API**: To render interactive maps, satellite imagery, and route lines. *(Subject to [Google Privacy Policy](https://policies.google.com/privacy))*
- **Firebase Cloud Messaging (Google)**: To deliver push notification alerts to your device. *(Subject to [Firebase Privacy Terms](https://firebase.google.com/support/privacy))*

We do not disclose data unless required by applicable law, regulation, or legal process.

---

## 4. Data Security & Retention

- **Encryption**: Data transmitted between the mobile app and our servers uses Transport Layer Security (TLS/HTTPS).
- **Local Protection**: Credentials and session tokens stored on your device use platform-isolated storage (`SharedPreferences`).
- **Data Retention**: Vehicle tracking logs are retained as long as your account remains active or as needed to provide historical route playback services.

---

## 5. User Rights & Account Deletion

- **Access & Update**: You can manage your account and vehicle list within the app.
- **Account & Data Deletion**: You can request the deletion of your account and associated vehicle tracking data at any time by contacting us at **otitsdi@gmail.com** or through the in-app support feature.
- **Permissions Control**: You can grant or revoke phone location or notification permissions anytime in your mobile device settings.

---

## 6. Children's Privacy

CapGPS is designed for commercial fleet management and vehicle monitoring by adult users. We do not knowingly collect personal information from children under the age of 13.

---

## 7. Contact Us

If you have any questions or requests regarding this Privacy Policy:

- **Email**: otitsdi@gmail.com
- **In-App Support**: CapGPS Support Button
- **Package Name**: `com.trackcapgps.app`
