# Fortify

A gamified disaster preparedness mobile app built for a final-year university project (CM3070). Players improve their real-world emergency readiness through RPG-style mechanics: earning XP, levelling up, completing quests with branching narratives, and tackling challenges that teach survival skills.

## Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** AppWrite Functions (Dart)
- **Database:** AppWrite Database
- **Auth:** AppWrite Auth
- **State:** Provider
- **Dependency Injection**: GetIt
- **Monorepo:** Melos

## Project Structure

```
project/
├── apps/fortify/           # Flutter mobile app
├── apis/
│   ├── functions/          # AppWrite Functions (each a standalone Dart project)
│   └── database/           # CLI tool to create AppWrite collections
├── packages/
│   ├── core/               # Shared domain models, enums, interfaces, use cases
│   └── infrastructure/     # Shared AppWrite data sources, mappers, auth
└── scripts/                # Build and deploy scripts
```

## Prerequisites

- Flutter SDK >=3.7.0
- Dart SDK >=3.4.3
- Melos (`dart pub global activate melos`)
- An AppWrite instance (cloud or self-hosted)

## Getting Started

```bash
# Bootstrap all packages
melos bootstrap

# Set up the database (fill in .env first)
cd apis/database
dart run lib/main.dart

# Run the app
cd apps/fortify
flutter run
```

## Tests

```bash
# Run core package tests
cd packages/core
dart test

# Run app tests
cd apps/fortify
flutter test
```
