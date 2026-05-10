# SECURITY STANDARDS

## Overview
These standards define the security foundation for the application. DO NOT implement backend security until specified; these are structural rules.

## Core Mandates
1. **Firebase App Check**: All Firebase interactions must enforce App Check verification.
2. **Secure Token Storage**: Authentication tokens and sensitive credentials must ONLY be stored using `flutter_secure_storage`. Do not use SharedPreferences for sensitive data.
3. **Environment Separation**: Maintain strict separation between `dev`, `staging`, and `production` configurations. Never hardcode environment variables.
4. **API Validation & DTO Sanitization**: All incoming data from APIs or Firestore must be parsed strictly through validated DTOs utilizing `json_serializable` and `freezed`. Treat all external data as untrusted.
5. **RBAC Preparation**: Ensure user models and authentication state can support Role-Based Access Control (RBAC) fields (e.g., user vs admin).
6. **Secure Logging**: Ensure `pretty_dio_logger` and console logs do NOT output sensitive information (tokens, PII, passwords) in production.
7. **Secret Handling**: Keep all API keys and secrets in environment files (e.g., `.env`) that are STRICTLY `.gitignore`d.
8. **Rate Limiting & SSL Pinning**: Architecture must accommodate future implementations of interceptor-based rate limiting handling and SSL pinning via Dio.
