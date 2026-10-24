🛡️ RescuSphere
Your Personal Emergency Response Companion

Flutter
Dart
Platform
License

RescuSphere is a powerful, life-saving mobile application designed to provide instant emergency assistance at the tap of a button. Whether you're facing a medical emergency, a natural disaster, or a personal safety threat — RescuSphere has your back.

Download APK · Features · Tech Stack · Contributing

🚀 Why RescuSphere?

"In an emergency, every second counts."

Traditional emergency apps are clunky and slow. RescuSphere is built with one philosophy: speed saves lives. With a single tap, your emergency contacts receive your live GPS location, your medical profile is ready for first responders, and help is on the way.

✨ Features
🔴 One-Tap SOS Alert
Instant emergency activation with a single button press
Sends SMS alerts with live GPS coordinates to all your emergency contacts
Includes a Google Maps link so contacts can navigate directly to your location
Strobe visual alarm — screen flashes to attract attention in emergencies
🧠 Smart Triage System
AI-guided emergency assessment questionnaire
Classifies emergencies into severity levels: 🟢 Green → 🟡 Yellow → 🔴 Red → ⚫ Black
Automatically dispatches alerts based on triage severity
Real-time GPS coordinates attached to every triage report
🏥 Medical ID Profile
Store critical health information: blood group, allergies, medical conditions
First-time setup wizard with intuitive chip selectors
Quick-pick chips for common allergies (Penicillin, Peanuts, Latex, etc.)
Quick-pick chips for conditions (Asthma, Diabetes, Epilepsy, etc.)
Editable anytime via bottom-sheet interface
Profile reset option for a fresh start
Status indicator on home screen shows Medical ID readiness
👥 ICE (In Case of Emergency) Contacts
Add unlimited emergency contacts with name, relation, and phone number
One-tap call and one-tap SMS directly from the contact card
Contacts receive automatic alerts during SOS activation
Status pill on home screen shows ICE contact readiness
📋 Incident Logs
Automatic logging of every emergency event with timestamps
Mark incidents as ✅ Resolved or 🔄 Reopen with a single tap
Filter tabs: All | Active | Resolved — with live counts
Delete individual logs or Clear All with confirmation
Full details: type, summary, GPS coordinates, and status
📞 Speed Dial Emergency Hotlines
One-tap access to critical Indian emergency numbers:
112 — National Emergency (SOS)
108 — Ambulance
100 — Police
101 — Fire Brigade
📍 Quick Share Location
Instantly share your live location with emergency contacts
Copies Google Maps link to clipboard for easy sharing
Sends location via SMS to all ICE contacts simultaneously
🎨 Modern Glass-Morphism UI
Beautiful dark theme with glass-morphism cards
Smooth gradient backgrounds and animations
Responsive design that works on all screen sizes
Material 3 design language
📱 App Screenshots
Home Screen	SOS Activation	Smart Triage
🏠 Speed Dial + Status Pills	🔴 Strobe Alarm + Alert Dispatch	🧠 Severity Assessment
Medical ID	ICE Contacts	Incident Logs
🏥 Profile Setup Wizard	👥 Quick Call & SMS	📋 Filter & Resolve
🛠️ Tech Stack
Technology	Purpose
Flutter 3.47.5	Cross-platform UI framework
Dart 3.13.4	Programming language
SQLite (sqflite)	Local database for offline-first storage
Geolocator	Real-time GPS location services
URL Launcher	SMS dispatch and phone call integration
Provider	State management
Google Fonts	Typography (Poppins)
Material 3	Modern design system
📂 Project Structure
rescusphere/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── database/
│   │   └── database_helper.dart     # SQLite database operations
│   ├── models/
│   │   ├── medical_profile.dart     # Medical ID data model
│   │   ├── ice_contact.dart         # Emergency contact model
│   │   └── incident_log.dart        # Incident log data model
│   ├── providers/
│   │   └── app_provider.dart        # State management (ChangeNotifier)
│   ├── screens/
│   │   ├── home_screen.dart         # Main dashboard with SOS
│   │   ├── medical_id_screen.dart   # Medical profile & ICE contacts
│   │   ├── incident_logs_screen.dart# Incident history & management
│   │   └── triage_screen.dart       # Smart triage questionnaire
│   ├── services/
│   │   └── emergency_service.dart   # GPS, SMS, calls (singleton)
│   ├── theme/
│   │   └── app_theme.dart           # Glass-morphism dark theme
│   └── widgets/
│       ├── sos_button.dart          # Animated SOS button widget
│       └── glass_card.dart          # Reusable glass-morphism card
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml      # Permissions configuration
├── pubspec.yaml                     # Dependencies
└── README.md                        # You are here!
⚡ Installation
Prerequisites
Flutter SDK 3.47.5 or later
Android Studio / VS Code
Android device or emulator (API 21+)
Build from Source
bash
# Clone the repository
git clone https://github.com/yourusername/rescusphere.git
cd rescusphere
# Install dependencies
flutter pub get
# Run in debug mode
flutter run
# Build release APK
flutter build apk --release

The release APK will be generated at:

build/app/outputs/flutter-apk/app-release.apk
Direct APK Install
Download the latest app-release.apk from Releases
Transfer to your Android device
Enable "Install from Unknown Sources" if prompted
Tap the APK to install
Grant all permissions (Location, SMS) on first launch
🔐 Permissions

RescuSphere requires the following permissions to function:

Permission	Purpose
ACCESS_FINE_LOCATION	Precise GPS for emergency alerts
ACCESS_COARSE_LOCATION	Approximate location fallback
SEND_SMS	Dispatch emergency SMS to contacts
CALL_PHONE	Speed dial emergency hotlines
VIBRATE	Haptic feedback during SOS
INTERNET	Map services and location lookup

Privacy Note: All data is stored locally on your device using SQLite. No data is sent to external servers. Your medical information and contacts never leave your phone.

🗺️ Roadmap
 One-tap SOS with GPS alerts
 Smart Triage severity assessment
 Medical ID with blood group & allergies
 ICE contact management
 Incident logging with resolve/reopen
 Speed dial emergency hotlines
 Strobe visual alarm
 Quick share live location
 🔜 Voice-activated SOS ("Hey RescuSphere!")
 🔜 Wearable device integration (WearOS)
 🔜 Offline maps with cached tiles
 🔜 Multi-language support (Hindi, Tamil, Telugu...)
 🔜 Emergency video recording
 🔜 Community safety alerts nearby
🤝 Contributing

Contributions are welcome! Here's how you can help:

Fork the repository
Create a feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request
📄 License

This project is licensed under the MIT License — see the LICENSE file for details.


 — Beautiful native apps in record time
Material Design 3
 — Google's open-source design system
Geolocator
 — Location services plugin
Emergency services of India 🇮🇳 — 112, 108, 100, 101
⭐ If RescuSphere can save even one life, it's worth it.
