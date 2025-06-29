
CarDocAI - Full Stack Application Overview
==========================================

Project Summary:
----------------
CarDocAI is an AI-powered car diagnostic application designed to assist vehicle users in identifying dashboard warning lights and engine issues. The app uses image and audio analysis powered by machine learning to provide users with accurate diagnostics, severity levels, recommendations, and relevant repair tutorials.

Technologies Used:
------------------
- Backend: Python, FastAPI, Supabase (PostgreSQL, Auth, Storage), HTTPx, OpenAI Gemini
- Frontend: Flutter (Dart), Firebase (Auth, Firestore, Cloud Storage)
- ML Models: Image classification and sound detection (deployed locally or via APIs)

Backend Structure:
------------------
1. **Authentication**: Handles user registration, login, session management.
2. **Diagnosis**: Routes for dashboard image and engine sound diagnosis.
3. **Services**:
   - `image_analyzer.py`: Detects dashboard lights and extracts light features.
   - `audio_analyzer.py`: Analyzes engine audio and matches sound patterns.
   - `youtube_service.py`: Finds specific YouTube tutorials per issue.
   - `gemini_service.py`: Summarizes results and generates user-friendly feedback.
4. **Database Layer**: Supabase client for saving diagnostics, results, logs.

Frontend Features:
------------------
- **Login & Registration** with Firebase authentication.
- **Dashboard Scan**: Users take/upload a dashboard photo and get warning light analysis.
- **Sound Diagnosis**: Record/upload engine sounds to detect potential issues.
- **Diagnostic History**: Displays past diagnostic records.
- **User Profile**: View/edit profile info, change password.
- **Help & Tutorials**: Shows YouTube repair guides linked to detected issues.

Database Schema (Key Tables):
-----------------------------
- `users`, `user_profiles`
- `diagnostic_records`, `diagnostic_results`
- `engine_sounds`, `warning_lights`
- `tutorials`, `tutorial_warning_junction`, `tutorial_sound_junction`
- `audit_logs`, `session_tokens`

Password Reset:
---------------
- The **"Forgot Password"** on the login screen should route through the same backend used by the in-app profile section for password updates.
- To fix inconsistencies, ensure Firebase `sendPasswordResetEmail()` or Supabase's password reset flow is integrated in both places.

Deployment:
-----------
- Backend: Deployed with Uvicorn + FastAPI
- Frontend: Build and deploy via Flutter to Android/iOS

Status:
-------
- Core functionality complete.
- Pending: Final UI refinements, tutorial linking improvements, ML model fine-tuning.

Author:
-------
CarDocAI Team | Updated: June 29, 2025
