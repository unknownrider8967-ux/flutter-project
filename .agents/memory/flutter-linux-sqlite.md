---
name: Flutter Linux SQLite setup
description: How to make sqflite work on Linux desktop in this Replit environment
---

On Linux desktop, sqflite needs sqflite_common_ffi + the sqlite Nix system package.

**Rule:** In `main()`, before `DatabaseService.initialize()`, call:
```dart
if (Platform.isLinux || Platform.isWindows) {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
```

**Why:** sqflite's default Android/iOS path resolver doesn't exist on Linux. sqflite_common_ffi delegates to the native libsqlite3.so, which must be installed separately.

**How to apply:**
- `pubspec.yaml`: add `sqflite_common_ffi: ^2.3.0`
- Nix: `installSystemDependencies({ packages: ["sqlite"] })`
- `lib/main.dart`: add the Platform guard above

The ATK-CRITICAL and GSettings CRITICAL log lines are harmless GTK/accessibility warnings — they do not indicate app errors.
