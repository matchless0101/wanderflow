import Foundation

struct UserProfile: Codable, Identifiable {
    var id: UUID
    var name: String
    var preferences: [String] // e.g., "Foodie", "History", "Nature"
    var budgetRange: ClosedRange<Double>
    var visitedPOIs: [UUID]
    var mbti: String?
    var personaTags: [String]?
    
    static let defaultProfile = UserProfile(
        id: UUID(),
        name: "Traveler",
        preferences: [],
        budgetRange: 0...1000,
        visitedPOIs: [],
        mbti: nil,
        personaTags: []
    )
}
