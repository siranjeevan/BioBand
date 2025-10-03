# Bio-Band Documentation

## Overview
Bio-Band (Nadi Pariksh) is a Flutter-based health monitoring application that connects to wearable devices to track vital signs and provide real-time health analytics.

## Documentation Structure

- [UI Documentation](ui_documentation.md) - Complete UI components and screens
- [API Documentation](api_documentation.md) - Backend services and endpoints
- [Business Logic Documentation](logic_documentation.md) - Core application logic and state management
- [Architecture Documentation](architecture_documentation.md) - System design and patterns

## Quick Start

1. **Prerequisites**
   - Flutter SDK 3.9.0+
   - Firebase project setup
   - Android/iOS development environment

2. **Installation**
   ```bash
   flutter pub get
   flutter run
   ```

3. **Configuration**
   - Add `.env` file with API endpoints
   - Configure Firebase options
   - Set up Google Sign-In

## Key Features

- Real-time vital signs monitoring (Heart Rate, SpO2, Steps, Calories)
- Device connectivity and management
- AI-powered health analytics
- Comprehensive health reports
- User authentication with Google Sign-In
- Cross-platform support (Android, iOS, Web)

## Project Structure

```
lib/
├── config/          # Configuration files
├── design_system/   # UI theme and components
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # API and external services
├── utils/           # Utility functions
└── widgets/         # Reusable UI components
```