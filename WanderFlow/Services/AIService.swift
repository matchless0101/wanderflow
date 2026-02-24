import Foundation
import Combine
import CoreLocation
import AMapNaviKit

// MARK: - AI Service Implementation
class AIService: ObservableObject, RouteOptimizing {
    static let shared = AIService()
    private let apiKey: String
    private let baseURL = "https://www.sophnet.com/api/open-apis/v1/chat/completions"
    private let amapBaseURL = "https://restapi.amap.com/v5/direction/driving"
    private let amapKey: String
    private let amapTimeout: TimeInterval = 1.5
    
    init() {
        self.apiKey = "_kW447xggdQ0dxGN_z6CU96NMii6HqsLOhoy0fDxcyle7klodI8_Ug-qrG9uRzfyImLU0ONyaz78mwGyRATt7w"
        self.amapKey = ProcessInfo.processInfo.environment["AMAP_API_KEY"]
            ?? (Bundle.main.object(forInfoDictionaryKey: "AMAP_API_KEY") as? String ?? "")
    }

    struct APIError: LocalizedError, Sendable {
        let statusCode: Int
        let body: String?
        let underlying: Error?
        
        var errorDescription: String? {
            var parts: [String] = ["HTTP \(statusCode)"]
            if let body, !body.isEmpty {
                parts.append(body)
            }
            if let underlying {
                parts.append(underlying.localizedDescription)
            }
            return parts.joined(separator: " | ")
        }
    }
    
    private func requestData(parameters: [String: Any]) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: baseURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                guard (200..<300).contains(response.statusCode) else {
                    let body = String(data: output.data, encoding: .utf8)
                    throw APIError(statusCode: response.statusCode, body: body, underlying: nil)
                }
                return output.data
            }
            .eraseToAnyPublisher()
    }
    
    func generateItinerary(prompt: String) -> AnyPublisher<Itinerary, Error> {
        // If no API Key, return mock immediately (for demo purposes)
        /*
        if apiKey.isEmpty || true { // Force Mock for now as Alamofire is missing in CLI env
            print("⚠️ No API Key found or Alamofire missing. Returning mock data.")
            return Just(Self.mockItinerary)
                .setFailureType(to: Error.self)
                .delay(for: .seconds(2), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
        */
        
        let systemPrompt = """
        You are a travel assistant for the Chaoshan region (Shantou, Chaozhou, Jieyang).
        Generate a structured itinerary based on the user's request.
        Return ONLY valid JSON with the following structure:
        {
            "title": "Trip Title",
            "days": [
                {
                    "day": 1,
                    "activities": [
                        { "time": "09:00", "poiName": "Place Name", "description": "Short description", "type": "Sightseeing", "eta": "09:00", "stayDurationMinutes": 60 }
                    ]
                }
            ]
        }
        """
        
        let parameters: [String: Any] = [
            "model": "gemini-3-pro-preview", // or gpt-4o
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        return requestData(parameters: parameters)
            .tryMap { data in
                do {
                    return try JSONDecoder().decode(OpenAIResponse.self, from: data)
                } catch {
                    let body = String(data: data, encoding: .utf8)
                    throw APIError(statusCode: 200, body: body, underlying: error)
                }
            }
            .tryMap { response in
                guard let content = response.choices.first?.message.content else {
                    throw URLError(.badServerResponse)
                }
                let cleanJSON = content.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "")
                
                guard let data = cleanJSON.data(using: .utf8) else {
                    throw URLError(.cannotDecodeContentData)
                }
                
                return try JSONDecoder().decode(Itinerary.self, from: data)
            }
            .eraseToAnyPublisher()
        
        // return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
    }
    
    func generateChat(prompt: String) -> AnyPublisher<String, Error> {
        let systemPrompt = """
        You are a helpful travel assistant for the Chaoshan region (Shantou, Chaozhou, Jieyang).
        Reply naturally to the user's message.
        """
        
        let parameters: [String: Any] = [
            "model": "gemini-3-pro-preview",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        return requestData(parameters: parameters)
            .tryMap { data in
                do {
                    return try JSONDecoder().decode(OpenAIResponse.self, from: data)
                } catch {
                    let body = String(data: data, encoding: .utf8)
                    throw APIError(statusCode: 200, body: body, underlying: error)
                }
            }
            .tryMap { response in
                guard let content = response.choices.first?.message.content else {
                    throw URLError(.badServerResponse)
                }
                return content
            }
            .eraseToAnyPublisher()
    }
    
    struct AMapServiceError: LocalizedError, Sendable {
        let info: String?
        let infocode: String?
        
        var errorDescription: String? {
            var parts: [String] = []
            if let info { parts.append(info) }
            if let infocode { parts.append(infocode) }
            return parts.isEmpty ? "AMap Error" : parts.joined(separator: " | ")
        }
    }
    
    func optimizeRoute(waypoints: [Waypoint], mode: TransportMode = .driving) -> AnyPublisher<OptimizedRoute, Error> {
        guard waypoints.count >= 2 else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let start = waypoints.first!.amapCoordinate
        let end = waypoints.last!.amapCoordinate
        let via = waypoints.dropFirst().dropLast().map { $0.amapCoordinate }
        
        return Future<OptimizedRoute, Error> { promise in
            Task {
                do {
                    let naviRoute: AMapNaviRoute
                    switch mode {
                    case .driving:
                        naviRoute = try await AmapManager.shared.calculateDriveRoute(start: start, end: end, waypoints: via)
                    case .walking:
                        // Walking usually doesn't support waypoints in basic API, using Start/End
                        naviRoute = try await AmapManager.shared.calculateWalkRoute(start: start, end: end)
                    case .cycling:
                        // Cycling usually doesn't support waypoints in basic API, using Start/End
                        naviRoute = try await AmapManager.shared.calculateRideRoute(start: start, end: end)
                    }
                    
                    let optimized = self.convertNaviRouteToOptimized(naviRoute)
                    print("Route optimize success: mode=\(mode.rawValue), waypoints=\(waypoints.count), polyline=\(optimized.polyline.count), distance=\(optimized.totalDistanceMeters)")
                    promise(.success(optimized))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func convertNaviRouteToOptimized(_ route: AMapNaviRoute) -> OptimizedRoute {
        let coords = route.routeCoordinates.compactMap { point -> RouteCoordinate? in
            return RouteCoordinate(latitude: Double(point.latitude), longitude: Double(point.longitude))
        }
        
        var segments: [RouteSegment] = []
        // Note: AMapNaviRoute structure varies by SDK version and type (Drive/Walk/Ride).
        // Standard AMapNaviRoute often uses 'routeSegments' or 'routePaths' but properties differ.
        // For MVP, we skip detailed step extraction or would need to parse 'routeSegments' if available.
        // If we need turn-by-turn text, we should use AMapSearchAPI (AMapDrivingRouteSearch) instead.
        /*
        if let steps = route.routeSteps {
            for step in steps {
                let segment = RouteSegment(
                    instruction: step.iconType.description,
                    distanceMeters: step.length,
                    durationSeconds: step.time,
                    action: nil
                )
                segments.append(segment)
            }
        }
        */
        
        var optimized = OptimizedRoute(
            polyline: coords,
            totalDistanceMeters: route.routeLength,
            totalDurationSeconds: route.routeTime,
            congestionIndex: 0,
            trafficLightCount: route.routeTrafficLightCount
        )
        optimized.segments = segments
        return optimized
    }
    
    // MARK: - Mock Data
    static var mockItinerary: Itinerary {
        Itinerary(
            title: "Taste of Chaoshan: 2-Day Food Trip",
            days: [
                DayPlan(day: 1, activities: [
                    Activity(time: "09:00", poiName: "Small Park (Old Town)", description: "Explore the colonial architecture.", type: "Sightseeing", eta: "09:00", stayDurationMinutes: 60),
                    Activity(time: "12:00", poiName: "Fuhe Cheng Beef Hotpot", description: "Authentic Chaoshan beef hotpot.", type: "Food", eta: "12:00", stayDurationMinutes: 90),
                    Activity(time: "15:00", poiName: "Queshi Scenic Area", description: "Nature walk with sea views.", type: "Nature", eta: "15:00", stayDurationMinutes: 90)
                ]),
                DayPlan(day: 2, activities: [
                    Activity(time: "10:00", poiName: "Guangji Bridge", description: "Ancient pontoon bridge.", type: "History", eta: "10:00", stayDurationMinutes: 60),
                    Activity(time: "13:00", poiName: "Paifang Street", description: "Street food and local snacks.", type: "Food", eta: "13:00", stayDurationMinutes: 90)
                ])
            ]
        )
    }
}
