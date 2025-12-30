# Claude's Mandatory Workflow

This document defines the mandatory steps I (Claude) MUST follow during development.
**No exceptions. These steps are non-negotiable.**

---

## Before EVERY Commit

### Step 1: Format Code
```bash
dart format .
```

### Step 2: Verify Format Passes CI Check
```bash
dart format --output=none --set-exit-if-changed .
```
If this fails, run `dart format .` again and include those files in the commit.

### Step 3: Run Static Analysis
```bash
flutter analyze
```
Must pass with no errors (warnings are acceptable).

### Step 4: Run Flutter Tests
```bash
flutter test
```
All tests must pass.

### Step 5: Run Cloud Functions Checks (if functions/ changed)
```bash
npm run lint --prefix functions
npm run build --prefix functions
```

### Step 6: Run Full Validation Script
```bash
./scripts/validate.sh
```

---

## Before EVERY Phase Completion

### 1. All commits for the phase are pushed
### 2. CI pipeline passes (check with `gh run list --limit 1`)
### 3. Update PHASE_COMPLETION_CHECKLIST.md
### 4. Update plan file with progress
### 5. Create summary of completed work

---

## Before EVERY Session End

### 1. Commit all pending changes
### 2. Verify CI passes
### 3. Update all markdown documentation:
   - `.claude/PHASE_COMPLETION_CHECKLIST.md`
   - `~/.claude/plans/*.md` (plan file)
### 4. Summarize what was done and what's next

---

## Quick Reference Commands

```bash
# Full validation
./scripts/validate.sh

# Check CI status
gh run list --limit 3

# View CI failure logs
gh run view <run-id> --log-failed

# Format and verify
dart format . && dart format --output=none --set-exit-if-changed .
```

---

## Common Mistakes to Avoid

1. **Forgetting to format before commit** - Always run `dart format .`
2. **Not checking CI after push** - Always verify with `gh run list`
3. **Not updating documentation** - Always update checklists and plan files
4. **Committing without running tests** - Always run `flutter test`
5. **Pushing without full validation** - Always run `./scripts/validate.sh`

---

## Enforcement

If any of these steps are skipped:
1. CI will likely fail
2. The user will need to fix issues later
3. Development velocity will be impacted

**ALWAYS follow this workflow. No shortcuts.**
