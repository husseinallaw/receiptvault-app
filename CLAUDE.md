# Claude Code Project Instructions

## Language Preference

**Always respond in English**, regardless of what language the user is speaking. Even if the user writes in Arabic (اللهجة الشامية/اللبنانية or فصحى), always reply in English.

## Project Context

This is **ReceiptVault** - a smart receipt scanning app for the Lebanese market with LBP/USD dual currency support.

### Tech Stack
- **Mobile**: Flutter 3.19+ with Clean Architecture
- **Backend**: Firebase (Auth, Firestore, Functions, Storage)
- **OCR**: Google Cloud Vision API
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local DB**: Drift (SQLite)

### Current Status
- Phase 1 (Foundation): Complete
- Phase 2 (Authentication): Complete
- Phase 3 (Receipt Scanning): In Progress

### Key Files
- `.claude/PHASE_COMPLETION_CHECKLIST.md` - Progress tracking
- `.claude/WORKFLOW.md` - Development workflow
- `.claude/agents/` - AI agent configurations
