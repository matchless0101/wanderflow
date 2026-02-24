import Foundation
import Combine
import CoreLocation
import AMapFoundationKit
import AMapLocationKit
import AMapSearchKit
import AMapNaviKit

class AmapManager: NSObject, ObservableObject {
    static let shared = AmapManager()
    
    // SDK Managers
    private lazy var locationManager = AMapLocationManager()
    private lazy var searchAPI: AMapSearchAPI? = AMapSearchAPI()
    private let naviManager = AMapNaviDriveManager.sharedInstance()
    private let walkManager = AMapNaviWalkManager.sharedInstance()
    private let rideManager = AMapNaviRideManager.sharedInstance()
    
    // Published properties for UI updates
    @Published var currentLocation: CLLocation?
    @Published var locationError: Error?
    @Published var searchResults: [AMapGeocode] = []
    @Published var poiSearchResults: [AMapPOI] = []
    @Published var naviRoute: AMapNaviRoute?
    @Published var naviError: Error?
    
    // Continuations for async tasks
    private var geocodeContinuation: CheckedContinuation<[AMapGeocode], Error>?
    private var poiContinuation: CheckedContinuation<[AMapPOI], Error>?
    private var routeContinuation: CheckedContinuation<AMapNaviRoute, Error>?
    private var hasApiKey = false
    
    override private init() {
        super.init()
        configurePrivacy()
        setupSDK()
        setupLocationManager()
        setupSearchAPI()
        setupNaviManager()
    }
    
    private func configurePrivacy() {
        AMapLocationManager.updatePrivacyShow(.didShow, privacyInfo: .didContain)
        AMapLocationManager.updatePrivacyAgree(.didAgree)
        print("AMap Privacy updated: show=didShow, info=didContain, agree=didAgree")
    }
    
    private func setupSDK() {
        let envKey = ProcessInfo.processInfo.environment["AMAP_API_KEY"] ?? ""
        let plistKey = Bundle.main.object(forInfoDictionaryKey: "AMAP_API_KEY") as? String ?? ""
        let key = !envKey.isEmpty ? envKey : plistKey
        if !key.isEmpty {
            AMapServices.shared().apiKey = key
        }
        hasApiKey = !key.isEmpty
        AMapServices.shared().enableHTTPS = true
        let source = !envKey.isEmpty ? "ENV" : (!plistKey.isEmpty ? "PLIST" : "NONE")
        print("AMap API Key Source: \(source), Length: \(key.count)")
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.locationTimeout = 5
        locationManager.reGeocodeTimeout = 5
    }
    
    private func setupSearchAPI() {
        searchAPI?.delegate = self
    }
    
    private func setupNaviManager() {
        naviManager.delegate = self
        walkManager.delegate = self
        rideManager.delegate = self
    }
    
    // MARK: - Public Methods
    
    func requestLocation() {
        locationManager.requestLocation(withReGeocode: true) { [weak self] (location, regeocode, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.locationError = error
                    return
                }
                self?.currentLocation = location
            }
        }
    }
    
    func searchGeocode(address: String, city: String? = nil) async throws -> [AMapGeocode] {
        if !hasApiKey {
            throw NSError(domain: "AmapManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "未配置高德 API Key"])
        }
        return try await withCheckedThrowingContinuation { continuation in
            // Cancel previous if any (simple implementation)
            if self.geocodeContinuation != nil {
                self.geocodeContinuation?.resume(throwing: NSError(domain: "AmapManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cancelled"]))
            }
            self.geocodeContinuation = continuation
            
            let request = AMapGeocodeSearchRequest()
            request.address = address
            request.city = city
            self.searchAPI?.aMapGeocodeSearch(request)
        }
    }
    
    func searchPOIKeywords(keyword: String, city: String? = nil, cityLimit: Bool = false) async throws -> [AMapPOI] {
        if !hasApiKey {
            throw NSError(domain: "AmapManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "未配置高德 API Key"])
        }
        return try await withCheckedThrowingContinuation { continuation in
            if self.poiContinuation != nil {
                self.poiContinuation?.resume(throwing: NSError(domain: "AmapManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cancelled"]))
            }
            self.poiContinuation = continuation
            
            let request = AMapPOIKeywordsSearchRequest()
            request.keywords = keyword
            request.city = city
            request.cityLimit = cityLimit
            request.offset = 20
            request.page = 1
            request.showFieldsType = .none
            self.searchAPI?.aMapPOIKeywordsSearch(request)
        }
    }
    
    func calculateDriveRoute(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D] = []) async throws -> AMapNaviRoute {
        return try await withCheckedThrowingContinuation { continuation in
            if self.routeContinuation != nil {
                self.routeContinuation?.resume(throwing: NSError(domain: "AmapManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cancelled"]))
            }
            self.routeContinuation = continuation
            
            let startPoint = AMapNaviPoint.location(withLatitude: CGFloat(start.latitude), longitude: CGFloat(start.longitude))
            let endPoint = AMapNaviPoint.location(withLatitude: CGFloat(end.latitude), longitude: CGFloat(end.longitude))
            let wayPoints = waypoints.compactMap { AMapNaviPoint.location(withLatitude: CGFloat($0.latitude), longitude: CGFloat($0.longitude)) }
            
            self.naviManager.calculateDriveRoute(withStart: [startPoint!], end: [endPoint!], wayPoints: wayPoints, drivingStrategy: .drivingStrategySingleDefault)
        }
    }

    func calculateWalkRoute(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) async throws -> AMapNaviRoute {
        return try await withCheckedThrowingContinuation { continuation in
            if self.routeContinuation != nil {
                self.routeContinuation?.resume(throwing: NSError(domain: "AmapManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cancelled"]))
            }
            self.routeContinuation = continuation
            
            let startPoint = AMapNaviPoint.location(withLatitude: CGFloat(start.latitude), longitude: CGFloat(start.longitude))
            let endPoint = AMapNaviPoint.location(withLatitude: CGFloat(end.latitude), longitude: CGFloat(end.longitude))
            
            self.walkManager.calculateWalkRoute(withStart: [startPoint!], end: [endPoint!])
        }
    }
    
    func calculateRideRoute(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) async throws -> AMapNaviRoute {
        return try await withCheckedThrowingContinuation { continuation in
            if self.routeContinuation != nil {
                self.routeContinuation?.resume(throwing: NSError(domain: "AmapManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cancelled"]))
            }
            self.routeContinuation = continuation
            
            let startPoint = AMapNaviPoint.location(withLatitude: CGFloat(start.latitude), longitude: CGFloat(start.longitude))
            let endPoint = AMapNaviPoint.location(withLatitude: CGFloat(end.latitude), longitude: CGFloat(end.longitude))
            
            self.rideManager.calculateRideRoute(withStart: startPoint!, end: endPoint!)
        }
    }
}

// MARK: - AMapLocationManagerDelegate
extension AmapManager: AMapLocationManagerDelegate {
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        DispatchQueue.main.async {
            self.locationError = error
        }
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode!) {
        // Real-time updates
    }
}

// MARK: - AMapSearchDelegate
extension AmapManager: AMapSearchDelegate {
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        let pois = response.pois ?? []
        poiContinuation?.resume(returning: pois)
        poiContinuation = nil
        DispatchQueue.main.async {
            self.poiSearchResults = pois
        }
    }
    
    func onGeocodeSearchDone(_ request: AMapGeocodeSearchRequest!, response: AMapGeocodeSearchResponse!) {
        if let geocodes = response.geocodes {
            geocodeContinuation?.resume(returning: geocodes)
            geocodeContinuation = nil
            DispatchQueue.main.async {
                self.searchResults = geocodes
            }
        } else {
            geocodeContinuation?.resume(returning: [])
            geocodeContinuation = nil
        }
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        if request is AMapGeocodeSearchRequest {
            geocodeContinuation?.resume(throwing: error)
            geocodeContinuation = nil
            return
        }
        if request is AMapPOISearchBaseRequest {
            poiContinuation?.resume(throwing: error)
            poiContinuation = nil
            return
        }
    }
}

// MARK: - AMapNaviDriveManagerDelegate
extension AmapManager: AMapNaviDriveManagerDelegate {
    func driveManager(_ driveManager: AMapNaviDriveManager, onCalculateRouteSuccessWith type: AMapNaviRoutePlanType) {
        // naviRoute is available in driveManager.naviRoute
        if let route = driveManager.naviRoute {
            routeContinuation?.resume(returning: route)
            routeContinuation = nil
            DispatchQueue.main.async {
                self.naviRoute = route
            }
        } else {
            routeContinuation?.resume(throwing: NSError(domain: "AmapManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "No route found"]))
            routeContinuation = nil
        }
    }
    
    func driveManager(_ driveManager: AMapNaviDriveManager, onCalculateRouteFailure error: Error) {
        routeContinuation?.resume(throwing: error)
        routeContinuation = nil
        DispatchQueue.main.async {
            self.naviError = error
        }
    }
}

// MARK: - AMapNaviWalkManagerDelegate
extension AmapManager: AMapNaviWalkManagerDelegate {
    func walkManager(_ walkManager: AMapNaviWalkManager, onCalculateRouteSuccessWith type: AMapNaviRoutePlanType) {
        if let route = walkManager.naviRoute {
            routeContinuation?.resume(returning: route)
            routeContinuation = nil
            DispatchQueue.main.async {
                self.naviRoute = route
            }
        } else {
            routeContinuation?.resume(throwing: NSError(domain: "AmapManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "No walk route found"]))
            routeContinuation = nil
        }
    }
    
    func walkManager(_ walkManager: AMapNaviWalkManager, onCalculateRouteFailure error: Error) {
        routeContinuation?.resume(throwing: error)
        routeContinuation = nil
        DispatchQueue.main.async {
            self.naviError = error
        }
    }
}

// MARK: - AMapNaviRideManagerDelegate
extension AmapManager: AMapNaviRideManagerDelegate {
    func rideManager(_ rideManager: AMapNaviRideManager, onCalculateRouteSuccessWith type: AMapNaviRoutePlanType) {
        if let route = rideManager.naviRoute {
            routeContinuation?.resume(returning: route)
            routeContinuation = nil
            DispatchQueue.main.async {
                self.naviRoute = route
            }
        } else {
            routeContinuation?.resume(throwing: NSError(domain: "AmapManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "No ride route found"]))
            routeContinuation = nil
        }
    }
    
    func rideManager(_ rideManager: AMapNaviRideManager, onCalculateRouteFailure error: Error) {
        routeContinuation?.resume(throwing: error)
        routeContinuation = nil
        DispatchQueue.main.async {
            self.naviError = error
        }
    }
}
