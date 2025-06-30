# ToDoMini

A mini to-do app built with Flutter for efficient and delightful task management.

## Features
- Add, edit, and delete tasks
- Set categories and priorities for tasks
- Assign due dates and reminders
- Mark tasks as completed or pending
- View statistics: total, completed, and pending tasks
- Search and filter tasks
- Light and dark theme support
- Local storage using SQLite

## Screenshots
<!-- Add screenshots of your app here if available -->

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (comes with Flutter)

### Installation
1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd todomini
   ```
2. Get the dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure
- `lib/`
  - `main.dart` - App entry point
  - `models/` - Task data model
  - `providers/` - State management (tasks, theme)
  - `screens/` - UI screens (home, add/edit task)
  - `services/` - Local database service
  - `widgets/` - Reusable UI components
  - `constants/` - App-wide constants and colors
- `assets/` - Animations and images

## Dependencies
- [provider](https://pub.dev/packages/provider)
- [sqflite](https://pub.dev/packages/sqflite)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [path](https://pub.dev/packages/path)
- [flutter_slidable](https://pub.dev/packages/flutter_slidable)
- [intl](https://pub.dev/packages/intl)
- [lottie](https://pub.dev/packages/lottie)
- [flutter_staggered_animations](https://pub.dev/packages/flutter_staggered_animations)
- [cupertino_icons](https://pub.dev/packages/cupertino_icons)

## License
This project is for educational and personal use.

---

For more information on Flutter, see the [official documentation](https://docs.flutter.dev/).
