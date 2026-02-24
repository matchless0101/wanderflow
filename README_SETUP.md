# WanderFlow Setup Guide

## 1. Add Dependencies
This project requires the following Swift Packages. Please open the project in Xcode (`WanderFlow.xcodeproj`) and add them via **File > Add Package Dependencies...**:

1.  **Alamofire**
    *   URL: `https://github.com/Alamofire/Alamofire.git`
    *   Version: `5.7.0` (or newer)
2.  **RealmSwift**
    *   URL: `https://github.com/realm/realm-swift.git`
    *   Version: `10.40.0` (or newer)

## 2. Configure AI API Key
The AI Service is currently stubbed. To enable real AI features:
1.  Open `WanderFlow/Services/AIService.swift`.
2.  Replace the stub implementation with a real API call using `Alamofire`.
3.  Set your API Key in the environment variable `OPENAI_API_KEY` or hardcode it for testing (not recommended for production).

## 3. Database
The `RealmManager.swift` file contains commented-out code. Once you have installed the RealmSwift package:
1.  Uncomment the `import RealmSwift` line.
2.  Uncomment the implementation code.
3.  Update your Models (`POI`, `UserProfile`) to inherit from `Object` if you wish to persist them directly, or create separate Realm objects.

## 4. Architecture
- **Core/**: Network, Database, Design System.
- **Features/**: UI Modules (Home, Map, Chat).
- **Models/**: Data structures.
- **Services/**: Business logic services.
