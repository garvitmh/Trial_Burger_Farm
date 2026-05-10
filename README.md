# Burger Farm Mobile Application

## Overview
Burger Farm is an enterprise-grade, premium mobile commerce application built with Flutter. It provides a highly optimized, dynamic, and secure ordering experience for customers, supporting advanced features like custom OTP authentication, real-time tracking, and a sleek design system.

## Architecture
This repository follows Clean Architecture principles tightly coupled with Riverpod for predictable and testable state management.
For detailed architectural choices and the dependency graph, refer to `/docs/ARCHITECTURE.md`.

## Governance & Documentation
The foundation of this project enforces strict governance. Please refer to:
- **`docs/ARCHITECTURE.md`**: Core structural and layer boundaries.
- **`docs/SECURITY_RULES.md`**: Secure storage, token handling, and Firebase guidelines.
- **`docs/GIT_WORKFLOW.md`**: Branching strategies, commit conventions, and CI/CD rules.
- **`docs/PROJECT_ROADMAP.md`**: High-level milestones and upcoming integrations.

## Getting Started

1. Ensure you have the latest stable version of Flutter installed.
2. Clone the repository and install dependencies:
   ```bash
   git clone https://github.com/burger-farm-app/burger-farm-app.git
   cd burger-farm-app
   flutter pub get
   ```
3. Request or configure the required Firebase environments (`.env` and `firebase_options.dart`).
4. Run the application:
   ```bash
   flutter run
   ```
