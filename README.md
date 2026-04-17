# ITJOBHUNT Platform (PBL6) 🌟

ITJOBHUNT is a comprehensive Flutter-based platform connecting Candidates with Recruiters, featuring advanced AI capabilities for CV scoring and profile matching. 

## 🚀 Key Features

* **Role-Based Access Control (RBAC)**: Tailored user interfaces and dedicated feature sets for **Candidates** and **Recruiters**.
* **AI-Powered Matching**: Advanced AI components used for dynamic CV scoring and automated profile filtering for recruiters.
* **Authentication**: Secure login including Google Sign-in integration and JWT-based session management.
* **Admin Dashboard**: Comprehensive "Action-first" dashboard for administrators with KPIs, Trend, and Funnel visualization.
* **Real-time Communication**: WebSockets (STOMP protocol) support for real-time interactions/notifications.
* **Location & Mapping**: Google Maps integration for exact job and company location tracking.
* **Rich Data Handling**: Support for uploading CVs via file picker, editing descriptions with an embedded Rich Text Editor (Flutter Quill), and detailed hierarchical address selection (Province, District, Ward).

## 🛠️ Technology Stack & Architecture

This project is built using modern Flutter development practices and follows a Feature-First / Clean Architecture approach ensuring high scalability and maintainability.

* **Framework & Language**: Flutter & Dart (SDK ^3.9.0)
* **Architecture**: Clean Architecture principles structured by features (`Domain`, `Data`, `Presentation` layers).
* **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Event-driven state management for predictable UI updates.
* **Dependency Injection**: [get_it](https://pub.dev/packages/get_it) - Decoupling implementations and managing services (Providers and Repositories).
* **Routing**: [go_router](https://pub.dev/packages/go_router) - Declarative routing to handle deep links and role-based navigation guards.
* **Networking & Data**: 
  * [dio](https://pub.dev/packages/dio) for robust HTTP requests.
  * [dartz](https://pub.dev/packages/dartz) for functional programming concepts like `Either` to handle API responses and failures gracefully.
* **UI & Styling**: Configurable UI with [google_fonts](https://pub.dev/packages/google_fonts), Custom SVG/Icons, and custom [awesome_dialog](https://pub.dev/packages/awesome_dialog) implementations to ensure a premium visual experience.

## 📁 Project Structure

The codebase is organized modularly inside the `lib/` directory:

```plaintext
lib/
├── core/             # Core utilities, base classes, constants, and network configs
├── features/         # Main application features (Auth, Routing, AI Matching, Recruiter Job/Profile, Candidate etc.)
│   ├── ai_matching/  # AI utilities (Data Sources, Domain Entities)
│   ├── recruiter/    # Recruiter specific modules (Job management, Applicants)
│   ├── shared/       # Shared features (Auth, Info editing, UI widgets)
│   └── user/         # Candidate features (Jobs viewing, CV Profile)
├── routes/           # App routing configurations based on roles
└── main.dart         # Entry point of the application
```

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK configured on your machine.
- IDE (VSCode, Android Studio, etc.) with Flutter extensions.

### Installation

1. Clone the repository.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

*Note: Ensure your backend services and API environment variables are properly configured before running the application.*
