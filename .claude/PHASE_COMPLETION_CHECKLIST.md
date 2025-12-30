# Phase Completion Checklist

This document defines the mandatory validation steps that must pass before any phase is considered complete. **No phase should be marked as done until ALL items are verified.**

---

## Automated Validation (CI Pipeline)

These checks run automatically on every PR:

| Check | Command | Must Pass |
|-------|---------|-----------|
| Code Generation (Drift) | `dart run build_runner build` | ✅ |
| Localization Generation | `flutter gen-l10n` | ✅ |
| Generated Files Exist | Verify `.g.dart` and l10n files | ✅ |
| Static Analysis | `flutter analyze` | ✅ |
| Code Formatting | `dart format --set-exit-if-changed .` | ✅ |
| Unit Tests | `flutter test` | ✅ |
| Cloud Functions Lint | `npm run lint` (in functions/) | ✅ |
| Cloud Functions Build | `npm run build` (in functions/) | ✅ |
| Cloud Functions Tests | `npm test` (in functions/) | ✅ |
| iOS Build | `flutter build ios --simulator` | ✅ |

---

## Manual Validation (Before Merging)

### Code Quality
- [ ] All new code follows Clean Architecture patterns
- [ ] No TODO comments left unresolved (or tracked in issues)
- [ ] No hardcoded strings (use l10n)
- [ ] No hardcoded colors (use theme)
- [ ] Error handling implemented for all external calls

### Documentation
- [ ] New files have doc comments explaining purpose
- [ ] Complex logic has inline comments
- [ ] Plan file updated if scope changed

### Testing
- [ ] Unit tests added for new business logic
- [ ] Edge cases considered and tested
- [ ] Error scenarios tested

### Security
- [ ] No secrets committed
- [ ] No sensitive data logged
- [ ] Input validation in place

---

## Phase-Specific Checklists

### Phase 1: Foundation Infrastructure

#### Sprint 1.1: Core Infrastructure
- [x] Error handling system (`failures.dart`, `exceptions.dart`, `error_handler.dart`)
- [x] Result type for functional error handling
- [x] Extensions (string, date, currency, context)
- [x] DI setup with Riverpod providers
- [x] Network utilities and Dio client

#### Sprint 1.2: Local Database (Drift)
- [x] Database schema defined
- [x] All tables created (receipts, items, budgets, stores, exchange_rates, sync_queue)
- [x] DAOs with CRUD operations
- [x] `.g.dart` file generated successfully
- [ ] Database migrations tested

#### Sprint 1.3: Navigation (GoRouter)
- [x] Router configuration
- [x] Route paths defined
- [x] Shell screen with bottom navigation
- [ ] Route guards (auth protection) - deferred to Phase 2
- [ ] Deep linking tested

#### Sprint 1.4: Localization (AR/EN)
- [x] ARB files with all strings
- [x] Localization delegates configured
- [x] Generated files present
- [ ] RTL layout tested (requires running app)
- [ ] All UI strings use localization

#### Phase 1 Completion Criteria
- [x] `flutter analyze` passes with no errors
- [x] `flutter test` passes
- [x] Code generation succeeds
- [ ] App runs on iOS simulator
- [x] CI pipeline passes all checks

---

### Phase 2: Authentication ✅ COMPLETE

#### Sprint 2.1: Domain Layer
- [x] User entity (`lib/domain/entities/user.dart`)
- [x] UserPreferences entity (`lib/domain/entities/user_preferences.dart`)
- [x] Auth repository interface (`lib/domain/repositories/auth_repository.dart`)
- [x] Use cases (sign_in_with_email, sign_in_with_google, sign_in_with_apple, sign_out, get_current_user, send_password_reset, sign_up_with_email)

#### Sprint 2.2: Data Layer
- [x] User model with JSON serialization (`lib/data/models/user_model.dart`)
- [x] UserPreferences model (`lib/data/models/user_preferences_model.dart`)
- [x] Firebase Auth data source (`lib/data/datasources/remote/firebase_auth_datasource.dart`)
- [x] Firestore user data source (`lib/data/datasources/remote/firestore_user_datasource.dart`)
- [x] Secure storage data source (`lib/data/datasources/local/secure_storage_datasource.dart`)
- [x] Repository implementation (`lib/data/repositories/auth_repository_impl.dart`)

#### Sprint 2.3: Presentation Layer
- [x] Auth state provider (`lib/presentation/providers/auth_provider.dart`)
- [x] Auth screen UI (`lib/presentation/screens/auth/auth_screen.dart`)
- [x] Social sign-in buttons (`lib/presentation/screens/auth/widgets/social_sign_in_button.dart`)
- [x] Email sign-in form (`lib/presentation/screens/auth/widgets/email_sign_in_form.dart`)
- [x] Splash screen with auth check (`lib/presentation/screens/splash/splash_screen.dart`)
- [x] Onboarding screen (placeholder) (`lib/presentation/screens/onboarding/onboarding_screen.dart`)

#### Phase 2 Completion Criteria
- [x] Can sign in with Google
- [ ] Can sign in with Apple (DEFERRED - needs Apple Developer account $99/year)
- [x] Can sign in with Email/Password
- [x] Can sign up with Email/Password
- [x] User document created in Firestore
- [x] Auth state persists across app restarts
- [x] Protected routes redirect unauthenticated users
- [x] Sign out working
- [x] All tests pass
- [x] CI pipeline passes

#### Phase 2 Bug Fixes (commit a205b50)
- [x] Fixed router Stack Overflow (changed ref.watch to ref.read in redirect)
- [x] Fixed auth screen infinite loop (removed clearError from listener)
- [x] Simplified splash screen (removed context lookups during init)
- [x] Added sign out button to Home screen for testing
- [x] Removed Apple Sign-In button (deferred)
- [x] Configured real Firebase credentials

---

### Phase 3: Receipt Scanning (NEXT)

#### Sprint 3.1: Domain Layer
- [ ] Receipt entity
- [ ] ReceiptItem entity
- [ ] Store entity
- [ ] Money value object
- [ ] Receipt repository interface
- [ ] Use cases (scan, get, update, delete, search)

#### Sprint 3.2: Data Layer
- [ ] Receipt model with JSON serialization
- [ ] ReceiptItem model
- [ ] Store model
- [ ] OCR result model
- [ ] Receipt local data source
- [ ] Receipt remote data source
- [ ] Firebase storage data source
- [ ] Repository implementation

#### Sprint 3.3: OCR Service
- [ ] OCR service (Cloud Vision API)
- [ ] OCR parser
- [ ] Receipt extractor (Lebanese format)
- [ ] Image processor

#### Sprint 3.4: Presentation Layer
- [ ] Scanner provider
- [ ] Receipts provider
- [ ] Scanner screen with camera
- [ ] Receipt review/edit screen
- [ ] Receipts list screen
- [ ] Receipt detail screen

#### Phase 3 Completion Criteria
- [ ] Can capture receipt photo
- [ ] OCR extracts text from receipt
- [ ] Can review and edit extracted data
- [ ] Receipt saved to local database
- [ ] Receipt synced to Firestore
- [ ] Receipt image uploaded to Firebase Storage
- [ ] Can view receipt history
- [ ] All tests pass
- [ ] CI pipeline passes

---

## Process for Each Phase

1. **Before Starting**
   - Review phase requirements in plan
   - Create feature branch from `develop`
   - Update this checklist with phase-specific items

2. **During Development**
   - Commit frequently with clear messages
   - Run local validation regularly
   - Update checklist as items complete

3. **Before PR**
   - Run full validation locally:
     ```bash
     dart run build_runner build --delete-conflicting-outputs
     flutter gen-l10n
     flutter analyze
     dart format .
     flutter test
     ```
   - Verify app runs (when possible)
   - Review all checklist items

4. **PR Review**
   - Wait for CI to pass ALL checks
   - Address any review feedback
   - Re-run validation after changes

5. **After Merge**
   - Verify `develop` branch CI passes
   - Update plan file to mark phase complete
   - Document any known issues or deferred items

---

## Quick Validation Script

Run this before creating a PR:

```bash
#!/bin/bash
set -e

echo "🔧 Generating code..."
dart run build_runner build --delete-conflicting-outputs

echo "🌍 Generating localization..."
flutter gen-l10n

echo "🔍 Running analysis..."
flutter analyze

echo "📝 Checking formatting..."
dart format --set-exit-if-changed .

echo "🧪 Running tests..."
flutter test

echo "✅ All validations passed!"
```

Save as `scripts/validate.sh` and run with `./scripts/validate.sh`
