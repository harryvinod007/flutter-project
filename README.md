# Sentinel - AI Powered Whistleblowing Platform

## Overview

Sentinel is a secure whistleblowing platform developed as an MCA Major Project. The system enables employees or users to anonymously report workplace misconduct while protecting their identity.

The platform combines a Flutter mobile application, a React-based web administration panel, and an Apache OpenNLP backend to provide an end-to-end complaint management system with AI-assisted analysis.

---

## Project Architecture

The Sentinel system consists of three repositories:

| Repository | Purpose |
|------------|---------|
| **Sentinel_App** | Flutter mobile application (Frontend) |
| **web-panel_Sentinel** | React.js web administration panel |
| **OpenNLPProject_Sentinel** | Java + Apache OpenNLP AI backend |

---

# Project Features

- Anonymous complaint submission
- Complaint tracking using unique token numbers
- Secure investigation chat
- Upload images and documents as evidence
- AI-based complaint categorization
- AI-based complaint intensity prediction
- Complaint management dashboard
- Investigation scheduling
- Firebase Authentication
- Firestore database integration
- Cloud Storage support
- Real-time updates

---

# Technologies Used

## Mobile Application

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging

---

## Web Panel

- React.js
- JavaScript
- Firebase
- Material UI

---

## AI Backend

- Java
- Apache OpenNLP
- Maven
- ONNX Runtime
- NLP Classification Models

---

# Repository Links

## Flutter Application

https://github.com/harryvinod007/Sentinel_App

Contains the mobile application used by whistleblowers.

---

## Web Administration Panel

https://github.com/harryvinod007/web-panel_Sentinel

Contains the administrator dashboard for reviewing and managing complaints.

---

## OpenNLP Backend

https://github.com/harryvinod007/OpenNLPProject_Sentinel

Contains the AI engine responsible for complaint classification and NLP processing.

---

# Installation Guide

## 1. Clone the Flutter Application

```bash
git clone https://github.com/harryvinod007/Sentinel_App.git
```

Enter the project

```bash
cd Sentinel_App
```

Install packages

```bash
flutter pub get
```

Run

```bash
flutter run
```

---

## 2. Clone the Web Panel

```bash
git clone https://github.com/harryvinod007/web-panel_Sentinel.git
```

Enter project

```bash
cd web-panel_Sentinel
```

Install dependencies

```bash
npm install
```

Run

```bash
npm start
```

The React application starts on

```
http://localhost:3000
```

---

## 3. Clone the OpenNLP Backend

```bash
git clone https://github.com/harryvinod007/OpenNLPProject_Sentinel.git
```

Enter project

```bash
cd OpenNLPProject_Sentinel
```

Compile

```bash
mvn clean install
```

Run

```bash
mvn exec:java
```

or execute the main Java class from your IDE.

---

# Firebase Setup

Before running the application, create a Firebase project and enable:

- Authentication
- Cloud Firestore
- Firebase Storage
- Cloud Messaging

Download

Android

```
google-services.json
```

and place it inside

```
android/app/
```

If running on iOS, also add

```
GoogleService-Info.plist
```

---

# Workflow

1. User anonymously submits a complaint.
2. Complaint is stored in Firebase.
3. OpenNLP backend analyzes the complaint.
4. Complaint category and severity are predicted.
5. Administrators review complaints through the web panel.
6. Investigation chat is scheduled.
7. User tracks complaint progress using the generated token.

---

# Contributors

- Harry Vinod P
- Navaneeth Sunil
- Hayden Benny
- Sreeram B
- Karthik Bineesh

Project Guide

**M. Soumya Krishnan**

---

# Academic Project

This project was developed as part of the Integrated MCA programme at Amrita Vishwa Vidyapeetham.
