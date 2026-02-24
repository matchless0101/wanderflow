# AI Chat & Itinerary Generation Implementation Plan

## 1. Overview
The goal is to implement a functional AI Chat interface that can generate structured travel itineraries for the Chaoshan region based on user input.

## 2. Components

### 2.1 AI Service (`AIService.swift`)
- **Action:** Refactor `AIService` to use `Alamofire` for real network requests.
- **API:** Use OpenAI Chat Completion API (`gpt-4o` or `gpt-3.5-turbo`) or Gemini equivalent.
- **Prompt Engineering:** Design a system prompt that instructs the AI to return JSON structured data, not just text.
- **Response Handling:** Decode JSON response into `Itinerary` model.

### 2.2 Models (`Itinerary.swift`, `POI.swift`)
- **Action:** Define `Itinerary` struct conforming to `Codable`.
- **Structure:**
  - `title`: String
  - `days`: [DayPlan]
    - `day`: Int
    - `activities`: [Activity]
      - `time`: String
      - `poiName`: String
      - `description`: String
      - `type`: POICategory

### 2.3 Chat View Model (`ChatViewModel.swift`)
- **Action:** Update `sendMessage` to parse the structured response.
- **State:** Manage `isLoading`, `messages` (user vs AI), and `currentItinerary` (to display the result card).

### 2.4 UI Components (`ChatView.swift`, `ItineraryCard.swift`)
- **Action:** Create `ItineraryCard` to display the generated plan visually (Liquid UI style).
- **Integration:** Embed `ItineraryCard` inside the chat stream or as a result overlay.

## 3. Step-by-Step Implementation

1.  **Define Models:** Create `Itinerary` and related structs in `Models/Itinerary.swift`.
2.  **Mock Data (for TDD):** Create a robust mock JSON for testing parsing logic.
3.  **Service Layer:** Implement `fetchItinerary(prompt:)` in `AIService` using `Alamofire`.
    *   *Note:* Will add a placeholder for API Key (user needs to provide one, or we use a mock for now if key is missing).
4.  **ViewModel Logic:** Connect View to Service.
5.  **UI Construction:** Build the `ItineraryCard` and update `ChatView`.
6.  **Testing:** Add Unit Tests for JSON parsing and ViewModel state.

## 4. Dependencies
- Alamofire (Already in Package.swift)
- OpenAI API (Requires Key)
