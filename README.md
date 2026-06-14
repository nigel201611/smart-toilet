# Smart Toilet

A Flutter app for controlling a smart toilet via MQTT over WiFi.

## Getting Started

### Prerequisites

- Flutter SDK ^3.12.2
- A running MQTT broker (default: `broker.emqx.io`)

### Setup

```bash
# Initialize git hooks and install dependencies
./setup.sh

# Or manually:
git config core.hooksPath git-hooks/
flutter pub get
```

### Git Hooks

This project uses git hooks for code quality enforcement:

- **pre-commit**: Runs `dart format --check` and `flutter analyze`
- **pre-push**: Runs `flutter test`

To skip hooks temporarily:
```bash
git commit --no-verify
git push --no-verify
```

### Running

```bash
flutter run
```
