# Release Build Guide

This guide explains the environment validation system that prevents accidental deployment of development credentials to production.

## Overview

The validation system automatically scans `lib/config/env.dart` for development indicators before building release versions of the app. This prevents shipping apps with localhost URLs or development server configurations.

---

## What Gets Validated

The system checks for these development indicators:

- `localhost` - Local development server
- `127.0.0.1` - Loopback address
- `0.0.0.0` - Wildcard address
- `http://10.*` - Private network ranges
- `http://192.168.*` - Private network ranges

If any of these are found in `lib/config/env.dart`, the release build will be **aborted**.

---

## Platform-Specific Setup

### Android

**No setup required.** The validation runs automatically.

The Gradle build system is configured to run validation before any release build:
- `flutter build apk --release`
- `flutter build appbundle --release`
- Any Gradle task containing "release" or "bundle"

If validation fails, you'll see:

```
╔═══════════════════════════════════════════════════════════════╗
║  ❌ CRITICAL: Development Credentials Detected!              ║
╚═══════════════════════════════════════════════════════════════╝

Found development indicators in lib/config/env.dart:
  ❌ localhost
     └─ Development server detected
```

### iOS

**One-time Xcode setup required.**

1. Open your project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. In the Project Navigator, select **Runner** (the blue project icon at the top)

3. Select the **Runner** target in the main panel

4. Click the **Build Phases** tab

5. Click the **+** button and select **New Run Script Phase**

6. Drag the new phase to position it **before "Compile Sources"**

7. Expand the **Run Script** section and paste this:
   ```bash
   "${SRCROOT}/../Scripts/validate_env.sh"
   ```

8. Optional: Rename the phase to "Validate Environment" for clarity

9. Close Xcode and test with:
   ```bash
   flutter build ios --release
   ```

The validation script will:
- Skip for debug builds (only runs on Release/Profile)
- Run the Dart validator
- Abort the build if development credentials are detected

---

## Testing the Validation

### Test with Development URLs (should fail)

1. Add a localhost URL to `lib/config/env.dart`:
   ```dart
   static const String apiBaseUrl = 'http://localhost:3000';
   ```

2. Try to build:
   ```bash
   # Android
   flutter build apk --release

   # iOS
   flutter build ios --release
   ```

3. The build should abort with a clear error message

### Test with Production URLs (should succeed)

1. Update `lib/config/env.dart` with production URLs:
   ```dart
   static const String apiBaseUrl = 'https://api.yourapp.com';
   ```

2. Build again - should complete successfully

---

## Manual Validation

You can run the validator manually at any time:

```bash
dart run tool/env_validator.dart
```

This is useful for:
- Pre-commit checks
- CI/CD pipelines
- Debugging configuration issues

---

## CI/CD Integration

The validation runs automatically in GitHub Actions. See `.github/workflows/validate-env.yml`.

Every pull request will validate the environment configuration before allowing merge.

---

## Troubleshooting

### "dart: command not found"

Ensure Flutter is in your PATH and Dart is installed:
```bash
flutter doctor
which dart
```

### Validation passes but shouldn't

Check that `lib/config/env.dart` contains the actual configuration being used. Some apps use multiple environment files or build flavors.

### Build still succeeds with localhost

**Android**: Check `android/app/build.gradle` for the validation task
**iOS**: Verify the Run Script Phase was added correctly in Xcode

### Permission denied on validate_env.sh

Make the script executable:
```bash
chmod +x ios/Scripts/validate_env.sh
```

---

## Disabling Validation (Not Recommended)

### Android

Comment out the task dependency in `android/app/build.gradle`:

```gradle
tasks.whenTaskAdded { task ->
    // if (task.name == 'assembleRelease' || ...) {
    //     task.dependsOn validateEnvironment
    // }
}
```

### iOS

Remove the Run Script Phase from Xcode Build Phases.

**Warning**: Disabling validation increases the risk of shipping development credentials to production.

---

## Environment Configuration Best Practices

1. **Use environment variables** for sensitive configuration
2. **Use build flavors** for dev/staging/production environments
3. **Never commit** API keys or secrets to version control
4. **Use a secrets manager** for production credentials
5. **Test release builds** before distribution

---

## Support

If you encounter issues with the validation system:

1. Check this documentation first
2. Run manual validation: `dart run tool/env_validator.dart`
3. Verify the validator script exists: `tool/env_validator.dart`
4. Check build output for detailed error messages

For questions about environment configuration, consult your team lead or DevOps team.
