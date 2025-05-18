# 🚨 Voice Shield – Empowering Women's Safety

Voice Shield is a mobile safety application designed to assist women in emergency situations using voice-activated alerts, real-time tracking, and instant contact with trusted people and authorities.

---

## 🔧 Project Steps (Development Workflow)

### 1. 📚 Requirement Analysis & Planning
- Identified issues with existing apps lacking hands-free and fast alerting.
- Decided on core goals: voice activation, location sharing, and real-time contact alerts.

### 2. 🔍 Literature Review
- Studied related systems using IoT, AI, GPS.
- Found gaps in usability and effectiveness of current safety tools.

### 3. 🧠 System Design
- Designed user-police-neighbor interaction model.
- Voice command triggers real-time tracking and alerts.

### 4. 🎨 UI/UX Design
- Simple and clean interface.
- Emergency buttons and visual indicators for threat level.

### 5. 🔑 Authentication & Personalization
- Login system with biometric support.
- Set personal emergency voice codes.

### 6. 🔁 Voice Activation & Automation
- Used AI and NLP for detecting emergency voice phrases.
- Included backup gesture triggers (e.g., phone shake).

### 7. 🌐 Real-Time Location Tracking
- Live GPS tracking.
- Firebase backend for sharing location with contacts and authorities.

### 8. 🧪 Testing
- Tested voice command under real-life conditions.
- Verified alert delivery, location accuracy, and UI responsiveness.

### 9. 🚀 Deployment
- Built using Flutter & Firebase.
- Tested on physical Android devices.

### 10. 📈 Result & Evaluation
- Achieved fast response time.
- Delivered alerts silently in noisy areas.

### 11. 🔮 Future Enhancements
- Multilingual support.
- Offline mode with mesh networking.
- Smartwatch integration.

---

## 🛠️ How to Run This Project

### 🔧 Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code
- Firebase account
- Git installed

### 🚀 Installation Steps

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/your-username/voice-shield.git
   cd voice-shield
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Connect Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable:
     - Authentication (Email/Phone)
     - Firestore
     - Realtime Database
   - Download `google-services.json` and place in:
     ```
     android/app/google-services.json
     ```

4. **Run the App**
   ```bash
   flutter run
   ```

### 📲 Test These Features

- Voice-activated alerts
- Shake detection trigger
- Live GPS location tracking
- Secure login system
- Real-time police & neighbor notification

### 💡 Notes

- Microphone & GPS permissions are required.
- Add emergency contacts before using alert system.
- Ensure Firebase rules support user access.

---

## ✅ Conclusion

Voice Shield provides a reliable, quick, and user-friendly emergency response tool designed to protect women in real-life situations. By combining voice activation, location sharing, and automated alert delivery, it ensures that help is always within reach — even when speaking out is the only option.
