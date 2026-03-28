
# 📚 Study Tracker App

A modern, elegant, and interactive learning tracker application built with **Flutter** and **Firebase**. Designed to help users maintain their study streaks, track focus time using a built-in Pomodoro timer, and visualize their productivity through beautiful charts.

## ✨ Features

* **🔐 Authentication:** Secure email and password login/registration powered by Firebase Auth.
* **⏱️ Live Focus Timer:** Built-in countdown timer (Pomodoro-style) to track study sessions in real-time. Features background state preservation (keeps running even when navigating between tabs).
* **📊 Interactive Statistics:** Weekly overview charts with dynamic gradients and daily averages, visualized using `fl_chart`.
* **🏷️ Categorized Logging:** Categorize learning sessions (Coding, Design, Business, Language) with distinct colors and icons.
* **🗑️ Swipe to Delete:** Intuitive UI to delete logs with swipe gestures, directly syncing with Firestore.
* **🎨 Modern UI/UX:** Dark mode, glassmorphism effects, glowing indicators, and smooth animations.

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Authentication, Cloud Firestore)
* **Key Packages:**
    * `firebase_core`, `firebase_auth`, `cloud_firestore`
    * `fl_chart` (For weekly statistical bar charts)
    * `percent_indicator` (For daily goal circular progress)

## 📸 Screenshots
*(TIPS: Nanti kamu bisa menambahkan link gambar screenshot aplikasimu di sini setelah di-upload ke GitHub)*
> `![Dashboard](link-gambar-dashboard)` | `![Timer](link-gambar-timer)` | `![Stats](link-gambar-stats)`

---

## 🚀 How to Clone and Run Locally

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites
Make sure you have the following installed on your system:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.x.x or higher)
* An IDE like **Android Studio** or **VS Code**
* Firebase CLI & FlutterFire CLI installed on your machine.

### Installation Steps

**1. Clone the repository**
```bash
git clone https://github.com/ANazmuddin/study_tracker.app.git
cd study-tracker
````

**2. Install dependencies**

```bash
flutter pub get
```

**3. Setup Firebase Configuration**
Since this project uses Firebase, you need to connect it to your own Firebase project.

  * Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
  * Enable **Authentication** (Email/Password) and **Firestore Database** (Start in Test Mode).
  * Run the FlutterFire CLI in the root of your project:
    ```bash
    flutterfire configure
    ```
  * Select your newly created Firebase project and choose the platforms (Android/iOS). This will generate the `lib/firebase_options.dart` file.

**4. Build Firestore Indexes (Important\!)**
To run the compound queries for the statistics, Firestore requires indexes.

  * Run the app. When you open the Dashboard or Stats page, check the debug console.
  * Click the auto-generated link in the console error message to automatically create the required composite indexes in your Firebase project.

**5. Run the Application**

```bash
flutter run
```

-----

## 👨‍💻 About the Author

Developed by **Ahmad Nazmuddin (Ahnan)**.
I am a final-year Computer Science student and a freelance Full Stack Web Developer with a strong passion for building responsive, scalable, and user-centric applications across both web and mobile platforms.

  * **GitHub:** [@ANazmuddin](https://www.google.com/search?q=https://github.com/ANazmuddin)
  * **LinkedIn:** [Ahmad Nazmuddin](https://www.google.com/search?q=https://linkedin.com/in/ahmadnazmuddin)
