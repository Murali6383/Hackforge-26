# 🛡️ SafeSphere – AI Powered Emergency & Gender Safety App

A hackathon-ready Flutter mobile application with AI-powered unsafe zone prediction, emergency SOS, real-time tracking, and community safety features.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.11+)
- Android Studio / VS Code
- Android device or emulator
- Python 3.9+ (for AI backend, optional)

### 1. Install Flutter Dependencies
```bash
cd d:\development\my_app
flutter pub get
```

### 2. Configure API Keys
Edit `lib/core/constants.dart` and replace:
- `YOUR_GOOGLE_MAPS_API_KEY` with your Google Maps API key
- `YOUR_TWILIO_SID` and `YOUR_TWILIO_AUTH_TOKEN` for SMS (optional)

Also update `android/app/src/main/AndroidManifest.xml`:
- Replace `YOUR_GOOGLE_MAPS_API_KEY` in the meta-data tag

> **Note:** The app works without API keys using mock data for demo/hackathon purposes.

### 3. Run the App
```bash
flutter run
```

### 4. Run AI Backend (Optional)
```bash
cd ai_backend
pip install -r requirements.txt
python app.py
```
The AI server runs on `http://localhost:5001`.

## 📱 Demo Credentials
- **Email:** `priya@demo.com`
- **Password:** any password
- **Volunteer:** `rahul@demo.com`
- **Authority:** `authority@demo.com`

## 📁 Project Structure
```
lib/
├── main.dart                  # App entry point
├── core/
│   ├── constants.dart         # Config, API URLs, colors
│   ├── app_theme.dart         # Dark theme
│   └── app_router.dart        # Named routes
├── models/
│   ├── user_model.dart        # User with emergency contacts
│   ├── emergency_event.dart   # SOS event with tracking
│   ├── safety_report.dart     # Community reports
│   ├── volunteer_model.dart   # Volunteer info
│   └── zone_risk.dart         # AI risk prediction
├── services/
│   ├── auth_service.dart      # Mock auth with SharedPrefs
│   ├── location_service.dart  # GPS tracking
│   ├── sos_service.dart       # SOS orchestration
│   ├── ai_service.dart        # AI risk prediction API
│   ├── websocket_service.dart # Real-time location sharing
│   ├── notification_service.dart
│   ├── database_service.dart  # SQLite offline storage
│   ├── report_service.dart    # Community reports
│   ├── sms_service.dart       # Twilio/SMS alerts
│   ├── voice_service.dart     # Voice SOS detection
│   └── fake_call_service.dart # Fake call simulation
├── providers/
│   ├── auth_provider.dart
│   ├── location_provider.dart
│   ├── emergency_provider.dart
│   └── map_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── dashboard_screen.dart
│   ├── map_screen.dart
│   ├── sos_active_screen.dart
│   ├── reports_screen.dart
│   ├── safe_route_screen.dart
│   ├── volunteer_screen.dart
│   ├── authority_dashboard_screen.dart
│   ├── fake_call_screen.dart
│   └── profile_screen.dart
└── widgets/
    ├── sos_button.dart
    ├── risk_badge.dart
    ├── stat_card.dart
    ├── report_card.dart
    └── volunteer_card.dart

ai_backend/
├── app.py               # Flask API server
└── requirements.txt     # Python deps
```

## 🔧 Features
| Feature | Status |
|---|---|
| User Auth (Register/Login) | ✅ |
| Emergency SOS Button | ✅ |
| Voice SOS ("Help me") | ✅ |
| Real-Time GPS Tracking | ✅ |
| AI Unsafe Zone Prediction | ✅ |
| Safety Heatmap on Map | ✅ |
| Community Safety Reports | ✅ |
| Safe Route Recommendation | ✅ |
| Volunteer Network | ✅ |
| Authority Dashboard | ✅ |
| Fake Call Simulation | ✅ |
| Offline SOS Caching (SQLite) | ✅ |
| SMS Alerts (Twilio scaffold) | ✅ |
| Safe Touch Home Shortcut | ✅ |

## 📄 License++++++++++++++++
MIT – Built for hackathon demonstration.
