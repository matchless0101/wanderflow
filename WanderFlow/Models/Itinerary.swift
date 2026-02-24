import Foundation
import CoreLocation
import Combine
import AMapSearchKit

struct CoordinateTransform {
    static func wgs84ToGcj02(_ coord: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        if outOfChina(coord) {
            return coord
        }
        let d = delta(coord)
        return CLLocationCoordinate2D(latitude: coord.latitude + d.latitude, longitude: coord.longitude + d.longitude)
    }
    
    static func gcj02ToWgs84(_ coord: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        if outOfChina(coord) {
            return coord
        }
        let d = delta(coord)
        let lat = coord.latitude * 2 - d.latitude
        let lon = coord.longitude * 2 - d.longitude
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    static func gcj02ToBd09(_ coord: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let x = coord.longitude
        let y = coord.latitude
        let z = sqrt(x * x + y * y) + 0.00002 * sin(y * Double.pi)
        let theta = atan2(y, x) + 0.000003 * cos(x * Double.pi)
        let bdLon = z * cos(theta) + 0.0065
        let bdLat = z * sin(theta) + 0.006
        return CLLocationCoordinate2D(latitude: bdLat, longitude: bdLon)
    }
    
    static func bd09ToGcj02(_ coord: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let x = coord.longitude - 0.0065
        let y = coord.latitude - 0.006
        let z = sqrt(x * x + y * y) - 0.00002 * sin(y * Double.pi)
        let theta = atan2(y, x) - 0.000003 * cos(x * Double.pi)
        let ggLon = z * cos(theta)
        let ggLat = z * sin(theta)
        return CLLocationCoordinate2D(latitude: ggLat, longitude: ggLon)
    }
    
    static func wgs84ToBd09(_ coord: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        gcj02ToBd09(wgs84ToGcj02(coord))
    }
    
    static func bd09ToWgs84(_ coord: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        gcj02ToWgs84(bd09ToGcj02(coord))
    }
    
    private static func delta(_ coord: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let a = 6378245.0
        let ee = 0.00669342162296594323
        let dLat = transformLat(coord.longitude - 105.0, coord.latitude - 35.0)
        let dLon = transformLon(coord.longitude - 105.0, coord.latitude - 35.0)
        let radLat = coord.latitude / 180.0 * Double.pi
        var magic = sin(radLat)
        magic = 1 - ee * magic * magic
        let sqrtMagic = sqrt(magic)
        let mgLat = coord.latitude + (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * Double.pi)
        let mgLon = coord.longitude + (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * Double.pi)
        return CLLocationCoordinate2D(latitude: mgLat, longitude: mgLon)
    }
    
    private static func transformLat(_ x: Double, _ y: Double) -> Double {
        var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x))
        ret += (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0
        ret += (20.0 * sin(y * Double.pi) + 40.0 * sin(y / 3.0 * Double.pi)) * 2.0 / 3.0
        ret += (160.0 * sin(y / 12.0 * Double.pi) + 320 * sin(y * Double.pi / 30.0)) * 2.0 / 3.0
        return ret
    }
    
    private static func transformLon(_ x: Double, _ y: Double) -> Double {
        var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x))
        ret += (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0
        ret += (20.0 * sin(x * Double.pi) + 40.0 * sin(x / 3.0 * Double.pi)) * 2.0 / 3.0
        ret += (150.0 * sin(x / 12.0 * Double.pi) + 300.0 * sin(x / 30.0 * Double.pi)) * 2.0 / 3.0
        return ret
    }
    
    private static func outOfChina(_ coord: CLLocationCoordinate2D) -> Bool {
        coord.longitude < 72.004 || coord.longitude > 137.8347 || coord.latitude < 0.8293 || coord.latitude > 55.8271
    }
}

struct Itinerary: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    let title: String
    let days: [DayPlan]
    
    enum CodingKeys: String, CodingKey {
        case title, days
    }
}

struct DayPlan: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    let day: Int
    let activities: [Activity]
    
    enum CodingKeys: String, CodingKey {
        case day, activities
    }
}

struct Activity: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    let time: String
    let poiName: String
    let description: String
    let type: String // e.g., "Food", "Sightseeing", "Transport"
    let latitude: Double?
    let longitude: Double?
    let eta: String?
    let stayDurationMinutes: Int?
    let coordinateSystem: CoordinateSystem?
    
    enum CodingKeys: String, CodingKey {
        case time, poiName, description, type, latitude, longitude, eta, stayDurationMinutes, coordinateSystem
    }

    init(id: UUID = UUID(), time: String, poiName: String, description: String, type: String, latitude: Double? = nil, longitude: Double? = nil, eta: String? = nil, stayDurationMinutes: Int? = nil, coordinateSystem: CoordinateSystem? = nil) {
        self.id = id
        self.time = time
        self.poiName = poiName
        self.description = description
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.eta = eta
        self.stayDurationMinutes = stayDurationMinutes
        self.coordinateSystem = coordinateSystem
    }
}

enum CoordinateSystem: String, Codable, Equatable {
    case wgs84
    case gcj02
    case bd09
}

enum TravelMode: String, Codable {
    case driving
    case taxi
    case transit
    case walking
}

enum WaypointKind: String, Codable {
    case start
    case stop
    case end
}

struct Waypoint: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let eta: String
    let stayDurationMinutes: Int
    let kind: WaypointKind
    let coordinateSystem: CoordinateSystem
    let isAutoCoordinateSystem: Bool
    
    var coordinate: CLLocationCoordinate2D {
        mapCoordinate
    }
    
    var rawCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var mapCoordinate: CLLocationCoordinate2D {
        switch coordinateSystem {
        case .wgs84:
            return CoordinateTransform.wgs84ToGcj02(rawCoordinate)
        case .gcj02:
            return rawCoordinate
        case .bd09:
            return CoordinateTransform.bd09ToGcj02(rawCoordinate)
        }
    }
    
    var amapCoordinate: CLLocationCoordinate2D {
        mapCoordinate
    }
    
    func withCoordinateSystem(_ system: CoordinateSystem, auto: Bool) -> Waypoint {
        Waypoint(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            eta: eta,
            stayDurationMinutes: stayDurationMinutes,
            kind: kind,
            coordinateSystem: system,
            isAutoCoordinateSystem: auto
        )
    }
    
    var stableKey: String {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return "\(normalizedName)|\(String(format: "%.6f", latitude))|\(String(format: "%.6f", longitude))"
    }
}

struct WaypointAdjustmentRecord: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    let timestamp: Date
    let latitude: Double
    let longitude: Double
}

struct WaypointAdjustment: Codable, Equatable {
    var offsetLatitude: Double
    var offsetLongitude: Double
    var isLocked: Bool
    var history: [WaypointAdjustmentRecord]
    var resolvedCoordinateSystem: CoordinateSystem?
}

struct DeviationWarning: Identifiable, Equatable {
    let id: UUID = UUID()
    let name: String
    let meters: Double
}

struct MapJumpTarget: Identifiable, Equatable {
    let id: UUID = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let source: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct RouteCoordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct OptimizedRoute: Codable, Equatable {
    let polyline: [RouteCoordinate]
    let totalDistanceMeters: Int
    let totalDurationSeconds: Int
    let congestionIndex: Double
    let trafficLightCount: Int
    
    // Detailed segments for turn-by-turn or list view
    var segments: [RouteSegment] = []
}

struct RouteSegment: Codable, Equatable, Identifiable {
    var id: String { instruction + "\(distanceMeters)" }
    let instruction: String
    let distanceMeters: Int
    let durationSeconds: Int
    let action: String? // e.g., "Turn Left", "Go Straight"
}

enum TransportMode: String, Codable, CaseIterable {
    case driving
    case walking
    case cycling
}

protocol RouteOptimizing {
    func optimizeRoute(waypoints: [Waypoint], mode: TransportMode) -> AnyPublisher<OptimizedRoute, Error>
}

extension Itinerary {
    func toWaypoints() -> [Waypoint] {
        let orderedActivities = days
            .sorted { $0.day < $1.day }
            .flatMap { $0.activities }
        guard !orderedActivities.isEmpty else { return [] }
        
        return orderedActivities.enumerated().compactMap { index, activity in
            guard let latitudeValue = activity.latitude, let longitudeValue = activity.longitude else {
                return nil
            }
            let normalized = normalizeCoordinate(latitude: latitudeValue, longitude: longitudeValue)
            let kind: WaypointKind
            if index == 0 {
                kind = .start
            } else if index == orderedActivities.count - 1 {
                kind = .end
            } else {
                kind = .stop
            }
            let coordinateSystem = activity.coordinateSystem ?? .wgs84
            let isAuto = activity.coordinateSystem == nil
            return Waypoint(
                name: activity.poiName,
                latitude: normalized.latitude,
                longitude: normalized.longitude,
                eta: activity.eta ?? activity.time,
                stayDurationMinutes: activity.stayDurationMinutes ?? 60,
                kind: kind,
                coordinateSystem: coordinateSystem,
                isAutoCoordinateSystem: isAuto
            )
        }
    }
    
    private func normalizeCoordinate(latitude: Double, longitude: Double) -> CLLocationCoordinate2D {
        if abs(latitude) > 90, abs(longitude) <= 90 {
            return CLLocationCoordinate2D(latitude: longitude.rounded(toPlaces: 6), longitude: latitude.rounded(toPlaces: 6))
        }
        return CLLocationCoordinate2D(latitude: latitude.rounded(toPlaces: 6), longitude: longitude.rounded(toPlaces: 6))
    }
}

final class RoutePlanStore: ObservableObject {
    @Published var waypoints: [Waypoint] = []
    @Published var optimizedRoute: OptimizedRoute?
    @Published var highlightWaypoints: [Waypoint] = []
    @Published var mapJumpTarget: MapJumpTarget?
    @Published var mapFocusToken: Int = 0
    @Published var mapTabJumpToken: Int = 0
    @Published var transportMode: TransportMode = .driving {
        didSet {
            optimizeRouteIfPossible()
        }
    }
    @Published var isOptimizing: Bool = false
    @Published var lastOptimizationError: String?
    @Published var deviationWarning: DeviationWarning?
    @Published private(set) var completedKeys: Set<String> = []
    @Published private(set) var travelMode: TravelMode = .driving
    @Published private(set) var adjustments: [String: WaypointAdjustment] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private let routeOptimizer: RouteOptimizing
    private let adjustmentsKey = "route_waypoint_adjustments_v1"
    private let completedKey = "route_completed_v1"
    private var coordinateCache: [String: CoordinateCacheEntry] = [:]
    private var geocodeTask: Task<Void, Never>?
    private var geocodeCache: [String: CLLocationCoordinate2D] = [:]
    private let fallbackCenter = CLLocationCoordinate2D(latitude: 23.657, longitude: 116.621)
    private let geocodeCacheKey = "route_geocode_cache_v1"
    private var geocodeDiskCache: [String: GeocodeCacheEntry] = [:]
    
    private struct ResolvedWaypointInput {
        let activity: Activity
        let coordinate: CLLocationCoordinate2D
        let coordinateSystem: CoordinateSystem
        let isAutoCoordinateSystem: Bool
    }
    
    init(routeOptimizer: RouteOptimizing = AIService.shared) {
        self.routeOptimizer = routeOptimizer
        loadAdjustments()
        loadCompleted()
        loadGeocodeCache()
    }
    
    func updateFromItinerary(_ itinerary: Itinerary) {
        geocodeTask?.cancel()
        optimizedRoute = nil
        lastOptimizationError = nil
        waypoints = []
        coordinateCache.removeAll()
        geocodeCache.removeAll()
        geocodeTask = Task { [weak self] in
            await self?.resolveWaypoints(from: itinerary)
        }
    }
    
    func optimizeRouteIfPossible() {
        guard waypoints.count >= 2 else {
            optimizedRoute = nil
            return
        }
        isOptimizing = true
        lastOptimizationError = nil
        routeOptimizer.optimizeRoute(waypoints: waypoints, mode: transportMode)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.isOptimizing = false
                if case .failure(let error) = completion {
                    self.lastOptimizationError = error.localizedDescription
                }
            }, receiveValue: { [weak self] route in
                guard let self else { return }
                print("Route optimized received: waypoints=\(self.waypoints.count), polyline=\(route.polyline.count), distance=\(route.totalDistanceMeters), duration=\(route.totalDurationSeconds)")
                self.optimizedRoute = route
                self.resolveCoordinateSystemIfNeeded(using: route)
            })
            .store(in: &cancellables)
    }

    private func resolveWaypoints(from itinerary: Itinerary) async {
        let orderedActivities = itinerary.days
            .sorted { $0.day < $1.day }
            .flatMap { $0.activities }
        print("Resolve waypoints start: activities=\(orderedActivities.count)")
        guard !orderedActivities.isEmpty else {
            await MainActor.run {
                self.waypoints = []
                self.optimizedRoute = nil
            }
            return
        }
        var resolved: [ResolvedWaypointInput] = []
        var failedCount = 0
        var usedFallback = false
        for (index, activity) in orderedActivities.enumerated() {
            if Task.isCancelled { return }
            if let latitude = activity.latitude, let longitude = activity.longitude {
                let normalized = normalizeCoordinate(latitude: latitude, longitude: longitude)
                let system = activity.coordinateSystem ?? .wgs84
                let isAuto = activity.coordinateSystem == nil
                resolved.append(
                    ResolvedWaypointInput(
                        activity: activity,
                        coordinate: normalized,
                        coordinateSystem: system,
                        isAutoCoordinateSystem: isAuto
                    )
                )
                continue
            }
            
            let cityHints = preferredCityHints(for: activity, itineraryTitle: itinerary.title)
            if let coordinate = await geocodeCoordinate(for: activity.poiName, cityHints: cityHints) {
                print("Geocode success: \(activity.poiName) -> \(coordinate.latitude),\(coordinate.longitude)")
                resolved.append(
                    ResolvedWaypointInput(
                        activity: activity,
                        coordinate: coordinate,
                        coordinateSystem: .gcj02,
                        isAutoCoordinateSystem: false
                    )
                )
                continue
            }
            
            print("Geocode failed: \(activity.poiName)")
            failedCount += 1
            usedFallback = true
            resolved.append(
                ResolvedWaypointInput(
                    activity: activity,
                    coordinate: fallbackCoordinate(for: index),
                    coordinateSystem: .gcj02,
                    isAutoCoordinateSystem: false
                )
            )
        }
        let builtWaypoints = buildWaypoints(from: resolved)
        await MainActor.run {
            if self.travelMode == .walking {
                self.waypoints = self.reorderForWalking(builtWaypoints)
            } else {
                self.waypoints = builtWaypoints
            }
            self.coordinateCache.removeAll()
            print("Resolve waypoints done: success=\(builtWaypoints.count), failed=\(failedCount)")
            self.pruneCompletedForCurrentWaypoints()
            if failedCount > 0 {
                self.lastOptimizationError = usedFallback ? "部分地点无法定位，已用默认位置展示" : "部分地点无法定位"
            } else {
                self.lastOptimizationError = nil
            }
            self.optimizeRouteIfPossible()
        }
    }

    private func buildWaypoints(from resolved: [ResolvedWaypointInput]) -> [Waypoint] {
        guard !resolved.isEmpty else { return [] }
        return resolved.enumerated().map { index, item in
            let kind: WaypointKind
            if index == 0 {
                kind = .start
            } else if index == resolved.count - 1 {
                kind = .end
            } else {
                kind = .stop
            }
            let activity = item.activity
            let coordinate = item.coordinate
            return Waypoint(
                name: activity.poiName,
                latitude: coordinate.latitude.rounded(toPlaces: 6),
                longitude: coordinate.longitude.rounded(toPlaces: 6),
                eta: activity.eta ?? activity.time,
                stayDurationMinutes: activity.stayDurationMinutes ?? 60,
                kind: kind,
                coordinateSystem: item.coordinateSystem,
                isAutoCoordinateSystem: item.isAutoCoordinateSystem
            )
        }
    }
    
    private func fallbackCoordinate(for index: Int) -> CLLocationCoordinate2D {
        let offset = Double(index) * 0.004
        return CLLocationCoordinate2D(latitude: fallbackCenter.latitude + offset, longitude: fallbackCenter.longitude + offset * 0.6)
    }

    private func geocodeCoordinate(for name: String, cityHints: [String]) async -> CLLocationCoordinate2D? {
        let key = normalizedGeocodeKey(name)
        if let cached = geocodeCache[key] {
            print("Geocode cache hit: \(name)")
            return cached
        }
        if let cached = geocodeDiskCache[key] {
            let coordinate = CLLocationCoordinate2D(latitude: cached.latitude, longitude: cached.longitude)
            geocodeCache[key] = coordinate
            print("Geocode disk cache hit: \(name)")
            return coordinate
        }
        let candidates: [String?] = [nil] + uniqueOrdered(cityHints).map { Optional($0) }
        let attempts = 2
        for city in candidates {
            for attempt in 0..<attempts {
                if Task.isCancelled { return nil }
                do {
                    let geocodes = try await AmapManager.shared.searchGeocode(address: name, city: city)
                    if let first = geocodes.first {
                        let coordinate = CLLocationCoordinate2D(latitude: Double(first.location.latitude).rounded(toPlaces: 6), longitude: Double(first.location.longitude).rounded(toPlaces: 6))
                        geocodeCache[key] = coordinate
                        geocodeDiskCache[key] = GeocodeCacheEntry(latitude: coordinate.latitude, longitude: coordinate.longitude, updatedAt: Date())
                        saveGeocodeCache()
                        return coordinate
                    }
                    print("Geocode empty result: \(name), city=\(city ?? "nil")")
                } catch {
                    print("Geocode error: \(name), city=\(city ?? "nil"), attempt=\(attempt + 1)")
                    if attempt < attempts - 1 {
                        try? await Task.sleep(nanoseconds: 600_000_000)
                    }
                }
            }
        }
        return nil
    }

    private func normalizedGeocodeKey(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    private func preferredCityHints(for activity: Activity, itineraryTitle: String) -> [String] {
        let corpus = "\(activity.poiName) \(activity.description) \(itineraryTitle)"
        let knownCities = [
            "潮州", "汕头", "揭阳", "普宁", "广州", "深圳", "珠海", "佛山", "东莞",
            "北京", "上海", "杭州", "南京", "苏州", "武汉", "长沙", "成都", "重庆",
            "西安", "天津", "青岛", "大连", "厦门", "福州", "昆明", "海口", "三亚"
        ]
        return knownCities.filter { corpus.contains($0) }
    }
    
    private func uniqueOrdered(_ values: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for value in values {
            if seen.insert(value).inserted {
                result.append(value)
            }
        }
        return result
    }
    
    private func normalizeCoordinate(latitude: Double, longitude: Double) -> CLLocationCoordinate2D {
        if abs(latitude) > 90, abs(longitude) <= 90 {
            return CLLocationCoordinate2D(
                latitude: longitude.rounded(toPlaces: 6),
                longitude: latitude.rounded(toPlaces: 6)
            )
        }
        return CLLocationCoordinate2D(
            latitude: latitude.rounded(toPlaces: 6),
            longitude: longitude.rounded(toPlaces: 6)
        )
    }
    
    private func resolveCoordinateSystemIfNeeded(using route: OptimizedRoute) {
        guard waypoints.contains(where: { $0.isAutoCoordinateSystem }) else { return }
        let routeCoords = route.polyline.map { $0.coordinate }
        guard !routeCoords.isEmpty else { return }
        let rawDistances = distancesFromWaypoints(waypoints: waypoints, transform: { $0.rawCoordinate }, routeCoords: routeCoords)
        let convertedDistances = distancesFromWaypoints(waypoints: waypoints, transform: { CoordinateTransform.wgs84ToGcj02($0.rawCoordinate) }, routeCoords: routeCoords)
        let rawMedian = median(rawDistances)
        let convertedMedian = median(convertedDistances)
        let resolved: CoordinateSystem = convertedMedian + 20 < rawMedian ? .wgs84 : .gcj02
        let autoKeys = waypoints.filter { $0.isAutoCoordinateSystem }.map { $0.stableKey }
        setResolvedCoordinateSystem(for: autoKeys, system: resolved)
    }
    
    private func distancesFromWaypoints(waypoints: [Waypoint], transform: (Waypoint) -> CLLocationCoordinate2D, routeCoords: [CLLocationCoordinate2D]) -> [CLLocationDistance] {
        let sampledRoute = stride(from: 0, to: routeCoords.count, by: 4).map { routeCoords[$0] }
        return waypoints.map { waypoint in
            let point = transform(waypoint)
            var minDistance = CLLocationDistance.greatestFiniteMagnitude
            for routePoint in sampledRoute {
                let distance = CLLocation(latitude: point.latitude, longitude: point.longitude)
                    .distance(from: CLLocation(latitude: routePoint.latitude, longitude: routePoint.longitude))
                if distance < minDistance {
                    minDistance = distance
                }
            }
            return minDistance
        }
    }
    
    private func median(_ values: [CLLocationDistance]) -> CLLocationDistance {
        let sorted = values.sorted()
        guard !sorted.isEmpty else { return 0 }
        let mid = sorted.count / 2
        if sorted.count % 2 == 0 {
            return (sorted[mid - 1] + sorted[mid]) / 2
        }
        return sorted[mid]
    }
    
    func displayCoordinate(for waypoint: Waypoint) -> CLLocationCoordinate2D {
        let key = waypoint.stableKey
        let system = resolvedCoordinateSystem(for: waypoint)
        let base = mapCoordinate(for: waypoint.rawCoordinate, system: system)
        let adjustment = adjustments[key]
        let offsetLat = adjustment?.offsetLatitude ?? 0
        let offsetLon = adjustment?.offsetLongitude ?? 0
        if let cached = coordinateCache[key],
           cached.baseLatitude == base.latitude,
           cached.baseLongitude == base.longitude,
           cached.offsetLatitude == offsetLat,
           cached.offsetLongitude == offsetLon {
            return cached.adjusted
        }
        let adjusted = CLLocationCoordinate2D(latitude: base.latitude + offsetLat, longitude: base.longitude + offsetLon)
        coordinateCache[key] = CoordinateCacheEntry(
            baseLatitude: base.latitude,
            baseLongitude: base.longitude,
            offsetLatitude: offsetLat,
            offsetLongitude: offsetLon,
            adjusted: adjusted
        )
        updateDeviationWarning(name: waypoint.name, base: base, adjusted: adjusted)
        return CLLocationCoordinate2D(latitude: adjusted.latitude.rounded(toPlaces: 6), longitude: adjusted.longitude.rounded(toPlaces: 6))
    }
    
    func addWaypoint(_ waypoint: Waypoint) {
        waypoints.append(waypoint)
        optimizeRouteIfPossible()
    }
    
    func removeWaypoint(id: UUID) {
        waypoints.removeAll { $0.id == id }
        optimizeRouteIfPossible()
    }
    
    func removeWaypoint(stableKey: String) {
        waypoints.removeAll { $0.stableKey == stableKey }
        optimizeRouteIfPossible()
    }
    
    func replaceWaypoints(_ newWaypoints: [Waypoint]) {
        waypoints = newWaypoints
        optimizeRouteIfPossible()
    }
    
    func clearWaypoints() {
        waypoints = []
        optimizedRoute = nil
    }
    
    func jumpToMapTarget(_ target: MapJumpTarget) {
        mapJumpTarget = target
        highlightWaypoints = [
            Waypoint(
                name: target.name,
                latitude: target.latitude,
                longitude: target.longitude,
                eta: "定位结果",
                stayDurationMinutes: 30,
                kind: .stop,
                coordinateSystem: .gcj02,
                isAutoCoordinateSystem: false
            )
        ]
        mapFocusToken += 1
        mapTabJumpToken += 1
    }
    
    func applyManualAdjustment(for waypoint: Waypoint, targetCoordinate: CLLocationCoordinate2D) {
        applyAdjustment(for: waypoint, targetCoordinate: targetCoordinate, recordHistory: true)
    }
    
    func applyKnownCoordinate(for waypoint: Waypoint, coordinate: CLLocationCoordinate2D, system: CoordinateSystem) {
        let target = mapCoordinate(for: coordinate, system: system)
        applyAdjustment(for: waypoint, targetCoordinate: target, recordHistory: true)
    }
    
    func applyKnownCoordinate(for waypoint: Waypoint, coordinate: CLLocationCoordinate2D, system: CoordinateSystem, shouldLock: Bool) {
        let target = mapCoordinate(for: coordinate, system: system)
        applyAdjustment(for: waypoint, targetCoordinate: target, recordHistory: true)
        if shouldLock {
            var adjustment = adjustments[waypoint.stableKey] ?? WaypointAdjustment(offsetLatitude: 0, offsetLongitude: 0, isLocked: false, history: [], resolvedCoordinateSystem: nil)
            adjustment.isLocked = true
            adjustments[waypoint.stableKey] = adjustment
            saveAdjustments()
        }
    }
    
    func toggleLock(for waypoint: Waypoint) {
        let key = waypoint.stableKey
        var adjustment = adjustments[key] ?? WaypointAdjustment(offsetLatitude: 0, offsetLongitude: 0, isLocked: false, history: [], resolvedCoordinateSystem: nil)
        adjustment.isLocked.toggle()
        adjustments[key] = adjustment
        saveAdjustments()
    }
    
    func isLocked(waypoint: Waypoint) -> Bool {
        adjustments[waypoint.stableKey]?.isLocked ?? false
    }
    
    func history(for waypoint: Waypoint) -> [WaypointAdjustmentRecord] {
        adjustments[waypoint.stableKey]?.history ?? []
    }
    
    func restoreHistory(for waypoint: Waypoint, recordId: UUID) {
        let key = waypoint.stableKey
        guard let record = adjustments[key]?.history.first(where: { $0.id == recordId }) else { return }
        let target = CLLocationCoordinate2D(latitude: record.latitude, longitude: record.longitude)
        applyAdjustment(for: waypoint, targetCoordinate: target, recordHistory: false)
    }
    
    private func applyAdjustment(for waypoint: Waypoint, targetCoordinate: CLLocationCoordinate2D, recordHistory: Bool) {
        let key = waypoint.stableKey
        let system = resolvedCoordinateSystem(for: waypoint)
        let base = mapCoordinate(for: waypoint.rawCoordinate, system: system)
        let offsetLat = targetCoordinate.latitude - base.latitude
        let offsetLon = targetCoordinate.longitude - base.longitude
        var adjustment = adjustments[key] ?? WaypointAdjustment(offsetLatitude: 0, offsetLongitude: 0, isLocked: false, history: [], resolvedCoordinateSystem: nil)
        adjustment.offsetLatitude = offsetLat
        adjustment.offsetLongitude = offsetLon
        if recordHistory {
            let record = WaypointAdjustmentRecord(timestamp: Date(), latitude: targetCoordinate.latitude, longitude: targetCoordinate.longitude)
            adjustment.history = Array((adjustment.history + [record]).suffix(20))
        }
        adjustments[key] = adjustment
        coordinateCache.removeValue(forKey: key)
        updateDeviationWarning(name: waypoint.name, base: base, adjusted: targetCoordinate)
        saveAdjustments()
    }
    
    private func resolvedCoordinateSystem(for waypoint: Waypoint) -> CoordinateSystem {
        if let resolved = adjustments[waypoint.stableKey]?.resolvedCoordinateSystem {
            return resolved
        }
        return waypoint.coordinateSystem
    }
    
    private func setResolvedCoordinateSystem(for keys: [String], system: CoordinateSystem) {
        var didChange = false
        for key in keys {
            var adjustment = adjustments[key] ?? WaypointAdjustment(offsetLatitude: 0, offsetLongitude: 0, isLocked: false, history: [], resolvedCoordinateSystem: nil)
            if adjustment.resolvedCoordinateSystem != system {
                adjustment.resolvedCoordinateSystem = system
                adjustments[key] = adjustment
                didChange = true
            }
        }
        if didChange {
            coordinateCache.removeAll()
            saveAdjustments()
        }
    }
    
    private func mapCoordinate(for coordinate: CLLocationCoordinate2D, system: CoordinateSystem) -> CLLocationCoordinate2D {
        switch system {
        case .wgs84:
            return CoordinateTransform.wgs84ToGcj02(coordinate)
        case .gcj02:
            return coordinate
        case .bd09:
            return CoordinateTransform.bd09ToGcj02(coordinate)
        }
    }
    
    private func updateDeviationWarning(name: String, base: CLLocationCoordinate2D, adjusted: CLLocationCoordinate2D) {
        let distance = CLLocation(latitude: base.latitude, longitude: base.longitude)
            .distance(from: CLLocation(latitude: adjusted.latitude, longitude: adjusted.longitude))
        if distance > 5 {
            deviationWarning = DeviationWarning(name: name, meters: distance)
        } else if deviationWarning != nil {
            deviationWarning = nil
        }
    }
    
    private func loadAdjustments() {
        guard let data = UserDefaults.standard.data(forKey: adjustmentsKey) else { return }
        let decoder = JSONDecoder()
        if let saved = try? decoder.decode([String: WaypointAdjustment].self, from: data) {
            adjustments = saved
        }
    }
    
    private func saveAdjustments() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(adjustments) {
            UserDefaults.standard.set(data, forKey: adjustmentsKey)
        }
    }
    
    func setTravelMode(_ mode: TravelMode) {
        travelMode = mode
    }
    
    private func reorderForWalking(_ original: [Waypoint]) -> [Waypoint] {
        guard original.count > 2 else { return original }
        var start = original.first!
        var end = original.last!
        var stops = Array(original.dropFirst().dropLast())
        var ordered: [Waypoint] = [start]
        var current = start
        while !stops.isEmpty {
            var bestIndex = 0
            var bestDistance = CLLocationDistance.greatestFiniteMagnitude
            for (i, s) in stops.enumerated() {
                let d = CLLocation(latitude: current.latitude, longitude: current.longitude)
                    .distance(from: CLLocation(latitude: s.latitude, longitude: s.longitude))
                if d < bestDistance {
                    bestDistance = d
                    bestIndex = i
                }
            }
            current = stops.remove(at: bestIndex)
            ordered.append(current)
        }
        ordered.append(end)
        return ordered
    }
    
    // MARK: - Completion State
    func markCompleted(_ waypoint: Waypoint) {
        completedKeys.insert(waypoint.stableKey)
        saveCompleted()
    }
    
    func unmarkCompleted(_ waypoint: Waypoint) {
        completedKeys.remove(waypoint.stableKey)
        saveCompleted()
    }
    
    func isCompleted(_ waypoint: Waypoint) -> Bool {
        completedKeys.contains(waypoint.stableKey)
    }
    
    func nextUncompletedIndex() -> Int? {
        for (i, w) in waypoints.enumerated() {
            if !isCompleted(w) { return i }
        }
        return nil
    }
    
    private func loadCompleted() {
        if let data = UserDefaults.standard.data(forKey: completedKey),
           let set = try? JSONDecoder().decode(Set<String>.self, from: data) {
            completedKeys = set
        }
    }
    
    private func saveCompleted() {
        if let data = try? JSONEncoder().encode(completedKeys) {
            UserDefaults.standard.set(data, forKey: completedKey)
        }
    }
    
    private func pruneCompletedForCurrentWaypoints() {
        let valid = Set(waypoints.map { $0.stableKey })
        let filtered = completedKeys.intersection(valid)
        if filtered != completedKeys {
            completedKeys = filtered
            saveCompleted()
        }
    }
    
    private func loadGeocodeCache() {
        guard let data = UserDefaults.standard.data(forKey: geocodeCacheKey) else { return }
        let decoder = JSONDecoder()
        if let saved = try? decoder.decode([String: GeocodeCacheEntry].self, from: data) {
            geocodeDiskCache = saved
        }
    }
    
    private func saveGeocodeCache() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(geocodeDiskCache) {
            UserDefaults.standard.set(data, forKey: geocodeCacheKey)
        }
    }
    
    private struct CoordinateCacheEntry {
        let baseLatitude: Double
        let baseLongitude: Double
        let offsetLatitude: Double
        let offsetLongitude: Double
        let adjusted: CLLocationCoordinate2D
    }
}

private struct GeocodeCacheEntry: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    let updatedAt: Date
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        guard places >= 0 else { return self }
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
