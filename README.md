# AI Signs

## Project Overview

This project implements a real-time Arabic Sign Language (ArSL) recognition system using deep learning and MediaPipe. The system captures live webcam input, extracts pose and hand landmarks, and classifies the performed sign language gestures using a trained Keras model.

The recognized signs are displayed as English phrases, providing an accessible interface for sign language understanding.

## Features

  - Real-time detection and classification of 40 Arabic sign language gestures.

  - Uses MediaPipe Holistic for robust pose and hand landmark extraction.

  - Deep learning model trained on normalized landmark sequences for accurate gesture recognition.

  - Continuous prediction smoothing via a prediction window to enhance reliability.

  - Displays recognized phrases in real-time on the webcam feed.

## Cloud Computing Integration

The project leverages modern cloud services to provide a seamless, scalable, and secure application experience:

### Firebase
Used for user authentication and real-time database management. Firebase Authentication ensures secure sign-in and identity management, while Firebase Realtime Database stores user-specific data, including user preferences and recognition history.

### Supabase
Utilized as a scalable storage backend. Supabase handles storing user data assets such as recorded videos or logs, providing fast and reliable object storage with easy API access.

### Netlify
Deployed the frontend application and model interface on Netlify, enabling fast, globally distributed hosting. Netlify also facilitates continuous deployment pipelines for seamless updates.

### WebView Integration
The recognition model and interface are embedded within a WebView in the application, allowing smooth integration of the deployed web app with native mobile or desktop environments.

## Future Work

  - Expand the sign vocabulary to include more phrases.

  - Improve UI/UX for accessibility.

  - Implement multi-language support.

  - Enhance cloud integration with analytics and usage monitoring.
