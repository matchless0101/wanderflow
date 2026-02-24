import Foundation
import CoreLocation

enum POICategory: String, Codable, CaseIterable {
    case attraction = "Attraction"
    case food = "Food"
    case hotel = "Hotel"
    case transport = "Transport"
}

struct POI: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: POICategory
    let coordinate: CLLocationCoordinate2D
    let description: String
    let imageURL: URL?
    let rating: Double
    let priceLevel: Int // 1-5
    
    // Accessibility & Metadata
    let isAccessible: Bool
    let openingHours: String
    let ticketLink: URL?
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, description, imageURL, rating, priceLevel, isAccessible, openingHours, ticketLink
        case latitude, longitude
    }
    
    init(id: UUID = UUID(), name: String, category: POICategory, coordinate: CLLocationCoordinate2D, description: String, imageURL: URL?, rating: Double, priceLevel: Int, isAccessible: Bool, openingHours: String, ticketLink: URL?) {
        self.id = id
        self.name = name
        self.category = category
        self.coordinate = coordinate
        self.description = description
        self.imageURL = imageURL
        self.rating = rating
        self.priceLevel = priceLevel
        self.isAccessible = isAccessible
        self.openingHours = openingHours
        self.ticketLink = ticketLink
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(POICategory.self, forKey: .category)
        description = try container.decode(String.self, forKey: .description)
        imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
        rating = try container.decode(Double.self, forKey: .rating)
        priceLevel = try container.decode(Int.self, forKey: .priceLevel)
        isAccessible = try container.decode(Bool.self, forKey: .isAccessible)
        openingHours = try container.decode(String.self, forKey: .openingHours)
        ticketLink = try container.decodeIfPresent(URL.self, forKey: .ticketLink)
        
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(description, forKey: .description)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(rating, forKey: .rating)
        try container.encode(priceLevel, forKey: .priceLevel)
        try container.encode(isAccessible, forKey: .isAccessible)
        try container.encode(openingHours, forKey: .openingHours)
        try container.encode(ticketLink, forKey: .ticketLink)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}
