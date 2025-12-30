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

### Phase 2: Authentication (Template)

#### Sprint 2.1: Domain Layer
- [ ] User entity
- [ ] Auth repository interface
- [ ] Use cases (sign in, sign out, get current user)

#### Sprint 2.2: Data Layer
- [ ] User model with JSON serialization
- [ ] Firebase Auth data source
- [ ] Firestore user data source
- [ ] Repository implementation

#### Sprint 2.3: Presentation Layer
- [ ] Auth state provider
- [ ] Auth screen UI
- [ ] Social sign-in buttons
- [ ] Splash screen with auth check
- [ ] Onboarding flow

#### Phase 2 Completion Criteria
- [ ] Can sign in with Google
- [ ] Can sign in with Apple
- [ ] Can sign in with Email
- [ ] User document created in Firestore
- [ ] Auth state persists across app restarts
- [ ] Protected routes redirect unauthenticated users
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
