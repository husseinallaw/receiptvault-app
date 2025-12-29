# ReceiptVault

Smart receipt scanning wallet for Lebanon with LBP/USD dual currency support.

## Features

- **Receipt Scanning**: OCR-powered receipt scanning using Google Cloud Vision API
- **Dual Currency**: Full support for LBP and USD with live exchange rates
- **Price Comparison**: Compare prices across Lebanese stores (Spinneys, Happy, Al Makhazen, etc.)
- **Budget Management**: Set and track budgets by category
- **Offline-First**: Works without internet, syncs when connected
- **Arabic Support**: Full RTL support with Arabic language option

## Tech Stack

- **Mobile**: Flutter 3.19+
- **Backend**: Firebase (Auth, Firestore, Functions, Storage)
- **OCR**: Google Cloud Vision API
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local DB**: Drift (SQLite)

## Project Structure

```
lib/
├── app/                    # App configuration, routes, theme
├── core/                   # Constants, utils, DI
├── data/                   # Models, datasources, repositories
├── domain/                 # Entities, usecases, interfaces
├── presentation/           # Screens, widgets, providers
└── services/               # OCR, sync, notifications

functions/                  # Firebase Cloud Functions (TypeScript)
firebase/                   # Firestore rules, indexes
.claude/agents/             # AI agent configurations
```

## AI Agent Team

This project includes 10 specialized AI agents for development:

1. **Project Manager** - Sprint planning and coordination
2. **Backend Developer** - Firebase/Cloud Functions
3. **Frontend Developer** - Flutter/Dart
4. **UI/UX Designer** - Design system
5. **ML/AI Engineer** - OCR pipeline
6. **Security Engineer** - Security reviews
7. **QA Testing** - Test coverage
8. **DevOps** - CI/CD pipelines
9. **Data Engineer** - Price comparison algorithms
10. **Technical Writer** - Documentation

## Getting Started

### Prerequisites

- Flutter 3.19+
- Node.js 18+
- Firebase CLI
- Xcode (for iOS)
- Android Studio (for Android)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/receiptvault-app.git
   cd receiptvault-app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   cd functions && npm install && cd ..
   ```

3. Configure Firebase:
   ```bash
   firebase login
   firebase use --add
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Development

### Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running Tests

```bash
flutter test
```

### Deploying Cloud Functions

```bash
cd functions
npm run deploy
```

## License

MIT License - see LICENSE file for details.
