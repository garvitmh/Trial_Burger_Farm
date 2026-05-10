# ARCHITECTURE

## Foundation
This project utilizes a feature-first, layered architecture.

## Structure Overview
### `app/`
Contains global application configurations, environment setup, routing (GoRouter), and bootstrap logic.

### `core/`
Contains cross-cutting concerns that apply across the entire application:
- Constants
- Errors/Exceptions
- Extensions
- Third-party Service Wrappers
- Network Interceptors
- Security Policies
- Theme/Design Tokens

### `features/`
Each feature is isolated and self-contained, separated into three distinct layers:
1. **Data Layer**: Repositories, DTOs, data sources (Firebase, APIs).
2. **Domain Layer**: Models, business logic, use cases (if needed).
3. **Presentation Layer**: UI, widgets specific to the feature, and Riverpod controllers/providers.

### `shared/`
Contains elements shared across multiple features but not globally fundamental like core/:
- Shared UI Widgets
- Shared Models/Types
- Cross-feature Providers

## State Management
- **Riverpod**: The sole state management solution.
- State must be immutable and represented using `Freezed`.
- Async operations handled via `AsyncValue` / `FutureProvider`.

## Routing
- **GoRouter**: Declarative routing system. Handles deep linking and auth-based redirection.

## Data Source
- **Firebase**: Used for Auth, Firestore, and App Check. Direct interaction is strictly prohibited from the Presentation layer.

## STRICT Dependency Direction
To maintain architectural purity, dependency flow must be strictly unidirectional.

**Allowed Flow:**
`Presentation` ➔ `Domain` ➔ `Data`

**Forbidden Flows:**
- `Presentation` ➔ `Data` directly (UI must never call repositories or APIs without domain/provider abstraction).
- `Feature A` ➔ `Feature B` directly (Features must not depend on other features).

**Cross-Feature Communication:**
Shared communication must ONLY happen through:
- Shared Contracts (`lib/shared/`)
- Shared Services
- App-Level Orchestration (global Riverpod providers)

## Additional Architectural Enforcement
- **Repository Abstraction Rules:** Repositories must define strict interfaces in the domain layer, with concrete implementations in the data layer (Dependency Inversion).
- **DTO Mapping Boundaries:** Data Transfer Objects (DTOs) belong strictly to the Data layer. They must be mapped to clean Domain Models before crossing into the Presentation layer. The UI must never see a `fromJson` or `toJson` operation.
- **Provider Ownership Rules:** Providers are scoped to the layer they serve. UI-specific state resides in the Presentation layer, while global data fetching resides in Domain/Data scoped providers.
