---
name: Auth approach — local only, no Firebase
description: How authentication works in SyncSphere after Firebase removal
---

Firebase was removed entirely (firebase_core, firebase_auth, google_sign_in) because Replit has no Firebase credentials and the app would crash at startup.

**Rule:** Use local auth via SharedPreferences + SHA-256 password hashing.

**Why:** Firebase requires Google credentials/google-services.json which can't be provided in a Replit environment.

**How to apply:**
- `lib/data/models/user_model.dart` — AppUser(id, name, email); replaces Firebase User
- `lib/presentation/auth/providers/auth_provider.dart` — login/signUp/logout/resetPassword all use SharedPreferences key 'users' (JSON list) + 'current_user_id'
- "Continue with Google" button creates a local demo account (id: 'demo-google-user') for quick testing — it is NOT a real OAuth flow
- Passwords are hashed with SHA-256 via the `crypto` package before storage
