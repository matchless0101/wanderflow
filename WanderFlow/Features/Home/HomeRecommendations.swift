import Foundation

struct FeaturedCase: Identifiable {
    let id: UUID
    let title: String
    let city: String
    let days: Int
    let tags: [String]
    let likes: Int
    let highlights: [String]
    
    init(id: UUID = UUID(), title: String, city: String, days: Int, tags: [String], likes: Int, highlights: [String]) {
        self.id = id
        self.title = title
        self.city = city
        self.days = days
        self.tags = tags
        self.likes = likes
        self.highlights = highlights
    }
}

enum HomeRecommendationSource {
    case featuredCase(FeaturedCase)
    case ai
}

final class FeaturedCasesRepository {
    static let shared = FeaturedCasesRepository()
    private init() {}
    
    let cases: [FeaturedCase] = [
        FeaturedCase(title: "潮州古城美食与人文 2 日", city: "潮州", days: 2, tags: ["Food", "History"], likes: 1240, highlights: ["牌坊街", "广济桥", "许驸马府", "砂锅粥"]),
        FeaturedCase(title: "汕头南澳海岛轻松 2 日", city: "汕头", days: 2, tags: ["Nature"], likes: 980, highlights: ["南澳岛", "青澳湾", "金银岛", "灯塔"]), 
        FeaturedCase(title: "揭阳古城与小众 3 日", city: "揭阳", days: 3, tags: ["History", "Culture"], likes: 670, highlights: ["学宫", "黄岐山", "榕城老街"])
    ]
}

final class HomeRecommender {
    func recommend(profile: UserProfile?, city: String?, days: Int?, tags: [String], budgetMax: Double?, travelMode: String, careMode: String) -> [Itinerary] {
        var filtered = FeaturedCasesRepository.shared.cases
        if let city, !city.isEmpty {
            filtered = filtered.filter { $0.city.contains(city) }
        }
        if let days, days > 0 {
            filtered = filtered.filter { $0.days == days }
        }
        if !tags.isEmpty {
            filtered = filtered.filter { item in
                !item.tags.filter { t in
                    tags.contains(where: { $0.lowercased().contains(Self.mapTag(t).lowercased()) || Self.mapTag($0).lowercased().contains(t.lowercased()) })
                }.isEmpty
            }
        }
        filtered.sort { a, b in
            Self.score(item: a, careMode: careMode, travelMode: travelMode) > Self.score(item: b, careMode: careMode, travelMode: travelMode)
        }
        if filtered.isEmpty {
            filtered = FeaturedCasesRepository.shared.cases
        }
        let top = Array(filtered.prefix(3))
        return top.map { Self.buildItinerary(from: $0) }
    }
    
    static func buildItinerary(from item: FeaturedCase) -> Itinerary {
        let activities = item.highlights.enumerated().map { idx, name in
            Activity(time: String(format: "%02d:00", 9 + idx), poiName: name, description: item.title, type: item.tags.first ?? "Sightseeing", eta: String(format: "%02d:00", 9 + idx), stayDurationMinutes: 60, coordinateSystem: .gcj02)
        }
        let dayPlan = DayPlan(day: 1, activities: activities)
        return Itinerary(title: item.title, days: [dayPlan])
    }
    static func mapTag(_ cn: String) -> String {
        switch cn {
        case "美食": return "Food"
        case "商场": return "Shopping"
        case "景点": return "Sightseeing"
        case "住宿": return "Hotel"
        default: return cn
        }
    }
    static func score(item: FeaturedCase, careMode: String, travelMode: String) -> Int {
        var s = item.likes
        if careMode == "携老携幼" {
            if item.tags.contains("History") { s += 200 }
            if item.days <= 2 { s += 100 }
        } else if careMode == "个人快节奏" || careMode == "特种兵" {
            if item.days >= 2 { s += 150 }
        } else if careMode == "出差" {
            if item.tags.contains("Food") { s += 120 }
        }
        if travelMode == "步行" {
            if item.city.contains("汕头") { s += 50 }
        }
        return s
    }
}
