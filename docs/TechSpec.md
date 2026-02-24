# WanderFlow Technical Specification

## 1. Architecture Overview
The application follows the **MVVM (Model-View-ViewModel)** pattern with **Combine** for reactive data binding.

### Layers:
1.  **Presentation Layer (SwiftUI):**
    - Views: Liquid/Organic UI components.
    - ViewModels: `ObservableObject`, transforming Domain models to View states.
2.  **Domain Layer:**
    - Use Cases: Business logic (e.g., `GenerateItineraryUseCase`).
    - Entities: Plain Swift structs (e.g., `POI`, `Itinerary`).
3.  **Data Layer:**
    - Repositories: `POIRepository`, `UserRepository`.
    - Data Sources:
        - **Remote:** `Alamofire` for API calls (AI, Weather, Sync).
        - **Local:** `RealmSwift` for offline persistence (User profile, cached POIs).

## 2. Key Modules

### 2.1 AI Service (`AIService`)
- **Interface:** `generateItinerary(prompt: String, context: UserContext) -> AnyPublisher<Itinerary, Error>`
- **Implementation:** Calls OpenAI/Gemini API.
- **Fallback:** Local CoreML model (simplified for MVP/Offline).

### 2.2 Map Module (`MapManager`)
- **Wrapper:** `MapKit` wrapper with custom overlays.
- **AR:** `ARKit` integration for "Real-world" navigation view.

### 2.3 Storage (`RealmManager`)
- **Schema:**
    - `UserProfile`: ID, preferences, history.
    - `POI`: ID, location, metadata (multilingual).
    - `Itinerary`: ID, generated steps.

## 3. UI Design System ("LiquidCore")
- **Components:**
    - `LiquidButton`: Button with fluid background.
    - `MorphingCard`: Card that changes shape on interaction.
    - `BreathingBackground`: Ambient animated background.
- **Tech:** SwiftUI `Canvas`, `TimelineView`, Metal Shaders (optional for high-end fluid effects).

## 4. Dependencies
- **Alamofire (5.7):** Networking.
- **RealmSwift (10.40):** Database.
- **Lottie (Optional):** Complex animations.
- **Factory (Optional):** Dependency Injection.

## 5. Project Structure
```
WanderFlow/
├── App/
│   ├── WanderFlowApp.swift
│   └── DependencyInjection.swift
├── Core/
│   ├── Network/ (Alamofire)
│   ├── Database/ (Realm)
│   └── DesignSystem/ (Liquid UI)
├── Features/
│   ├── Home/
│   ├── Chat/ (AI)
│   ├── Map/
│   └── Profile/
├── Models/
│   ├── POI.swift
│   └── User.swift
└── Resources/
```
