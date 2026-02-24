# WanderFlow Product Requirements Document (PRD)

## 1. Introduction
WanderFlow is a next-generation iOS travel application designed for the mass market, leveraging the "iOS 26" design language (Liquid/Organic UI). It integrates advanced AI capabilities to provide hyper-personalized travel itineraries for the Chaoshan region (Shantou, Chaozhou, Jieyang, Shanwei).

## 2. Core Features

### 2.1 AI-Powered Itinerary Generation
- **Input:** User profile, preferences, history, real-time weather, season, budget.
- **Interaction:** Natural language chat interface.
- **Output:** Structured itinerary including:
  - POI sequence
  - Transport modes & time estimates
  - Cost estimates
  - Dining recommendations
  - "Avoid Pitfalls" tips
- **Tech:** OpenAI/Gemini API integration (Real-time).

### 2.2 Intelligent Maps & Navigation
- **Map:** High-precision map interface (Simulated via MapKit for MVP).
- **Navigation:** AR integration for walking directions.
- **Offline:** Caching support for weak network environments.
- **Precision:** Target 0.3m accuracy (simulated logic).

### 2.3 Multi-Language POI Data
- **Languages:** Simplified Chinese, Traditional Chinese, English, Japanese, Korean.
- **Content:** Official images, opening hours, ticket booking links, accessibility info.

### 2.4 User Growth System
- **Actions:** Check-ins, Reviews, Sharing.
- **Rewards:** Points system redeemable for local coupons.

### 2.5 Admin Dashboard (Concept)
- POI management, price adjustments, event notifications.

## 3. User Interface (iOS 26 Style)
- **Concept:** Liquid Flow / Biological / Organic.
- **Characteristics:**
  - Fluid transitions (no hard cuts).
  - Morphing shapes.
  - "Breathing" elements.
  - Glassmorphism + Liquid dynamics.

## 4. Technical Constraints
- **OS:** iOS 16+
- **Language:** Swift 5.9+
- **Architecture:** MVVM + Combine
- **Network:** Alamofire 5.7
- **Database:** RealmSwift 10.40
- **AI:** Hybrid (CoreML local + Cloud API)
- **Performance:** Response < 800ms, Launch < 2s, Crash rate < 0.1%.

## 5. Delivery Requirements
- Xcode 15 Project.
- Unit Test Coverage ≥ 85%.
- UI Tests ≥ 50 cases.
- POI Dataset (Chaoshan region).
