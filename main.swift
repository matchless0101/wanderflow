import Foundation
import Combine
import CoreLocation

// Simple assertion helper
func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "") {
    if a != b {
        print("❌ Assertion Failed: \(a) != \(b). \(message)")
        exit(1)
    }
}

func assertTrue(_ condition: Bool, _ message: String = "") {
    if !condition {
        print("❌ Assertion Failed: Expected true. \(message)")
        exit(1)
    }
}

// MARK: - Tests

func testPOIDecoding() {
    print("Running testPOIDecoding...")
    let json = """
    {
        "id": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
        "name": "Small Park",
        "category": "Attraction",
        "description": "Historical area",
        "rating": 4.5,
        "priceLevel": 1,
        "isAccessible": true,
        "openingHours": "09:00-18:00",
        "ticketLink": "https://example.com",
        "latitude": 23.3541,
        "longitude": 116.6815
    }
    """.data(using: .utf8)!
    
    let decoder = JSONDecoder()
    do {
        let poi = try decoder.decode(POI.self, from: json)
        assertEqual(poi.name, "Small Park")
        assertEqual(poi.category, .attraction)
        assertEqual(poi.rating, 4.5)
        // Approximate float comparison
        assertTrue(abs(poi.coordinate.latitude - 23.3541) < 0.0001, "Latitude mismatch")
        print("✅ testPOIDecoding Passed")
    } catch {
        print("❌ Decoding failed: \(error)")
        exit(1)
    }
}

func testUserProfileDefaults() {
    print("Running testUserProfileDefaults...")
    let user = UserProfile.defaultProfile
    assertEqual(user.budgetRange, 0...1000)
    assertTrue(user.visitedPOIs.isEmpty)
    print("✅ testUserProfileDefaults Passed")
}

func testAIServiceStub() {
    print("Running testAIServiceStub...")
    let service = AIService.shared
    let user = UserProfile.defaultProfile
    let semaphore = DispatchSemaphore(value: 0)
    
    var receivedResponse: String?
    
    let cancellable = service.generateItinerary(user: user, context: "Test")
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("❌ AI Service failed: \(error)")
                exit(1)
            }
        }, receiveValue: { response in
            receivedResponse = response
            semaphore.signal()
        })
    
    let result = semaphore.wait(timeout: .now() + 5)
    if result == .timedOut {
        print("❌ AI Service timed out")
        exit(1)
    }
    
    if let response = receivedResponse {
        assertTrue(response.localizedCaseInsensitiveContains("itinerary"), "Response should contain itinerary")
        print("✅ testAIServiceStub Passed")
    } else {
        print("❌ No response received")
        exit(1)
    }
    
    cancellable.cancel()
}

// MARK: - Main Execution
testPOIDecoding()
testUserProfileDefaults()
testAIServiceStub()

print("\n🎉 All Logic Tests Passed!")
