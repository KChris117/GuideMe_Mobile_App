# 🗺️ GuideME - Batam Tour & Ticket Booking App

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)
![Midtrans](https://img.shields.io/badge/Midtrans-00A9E0?style=for-the-badge&logo=midtrans&logoColor=white)

**GuideME** is a mobile application built with Flutter to help users discover and book tourism tickets in Batam, Indonesia. The app provides a seamless experience from finding destinations, booking tickets, to securely completing payments.

## ✨ Key Features

- **📱 Modern & Beautiful UI/UX**: Designed with a clean, responsive, and intuitive interface.
- **🔐 Secure Authentication**: User Login and Registration powered securely by **Firebase Authentication**.
- **☁️ Real-time Database**: Tourism data, ticket stocks, and user purchase history are managed efficiently using **Cloud Firestore**.
- **💸 Integrated Payment Gateway**: Fully integrated with **Midtrans Sandbox** to handle online transactions safely.
- **💳 Multi-Payment Support**: Supports dynamic payment methods such as **QRIS, GoPay, Virtual Accounts (VA), and Credit Cards** via Midtrans' Snap In-App Browser.
- **🔄 Auto-Sync Status**: The app intelligently checks and updates transaction statuses (Pending, Completed, Expired) in real-time without requiring manual user input.

## 🛠️ Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend as a Service (BaaS)**: Firebase (Auth & Firestore)
- **Payment Gateway**: Midtrans (Snap API)
- **State Management**: Provider

## 📸 Screenshots

*(You can add screenshots of your app here later by uploading them to an `assets/images` folder in your repo)*
- `Home Screen` | `Detail Screen` | `Payment Screen` | `History Screen`

## 🚀 Getting Started

Follow these instructions to run the project on your local machine for development and testing.

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- Android Studio / VS Code
- A valid `google-services.json` file from Firebase (place it in `android/app/`).
- Midtrans Server/Client keys for Sandbox testing.

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/guideme-app.git
   cd guideme-app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## ⚠️ Important Note (Sandbox Mode)
This application is currently running in **Sandbox Mode** for testing purposes. **DO NOT** use real money or actual credit cards to make transactions in this app. Please use the dummy credentials provided by the [Midtrans Simulator](https://simulator.sandbox.midtrans.com/).

## 👥 Team & Contributors

This project was built collaboratively by an amazing team:

- **Firmansyah Pramudia Ariyanto**
  *Team Leader | Full Stack Developer | UI/UX Designer | Documentation Manager*
- **Christoffel Aristo Marbun**
  *Team Member | Full Stack Developer | UI/UX Designer | Documentation Contributor*
- **Rachel Hartati Simbolon**
  *Team Member | UI/UX Designer | Documentation Manager*
- **Isma Rapmaria Silitonga**
  *Team Member | UI/UX Designer | Documentation Contributor*
- **Asyri Dwi Yanti Ningsih**
  *Team Member | Documentation Contributor*

---
*Developed by the GuideME Team (PBL-IF-12).*
