import SwiftUI
import CoreLocation
import UIKit
import AMapNaviKit.MAMapKit

struct AmapViewWrapper: UIViewRepresentable {
    @Binding var route: OptimizedRoute?
    var transportMode: TransportMode = .driving
    var overlayWaypoints: [Waypoint] = []
    var displayCoordinate: ((Waypoint) -> CLLocationCoordinate2D)?
    var onOverlayPointsChange: (([String: CGPoint]) -> Void)?
    var focusTargetCoordinate: CLLocationCoordinate2D?
    var focusTargetToken: Int = 0
    var focusUserLocationToken: Int = 0

    func makeUIView(context: Context) -> MAMapView {
        _ = AmapManager.shared
        let mapView = MAMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.zoomLevel = 14
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = false
        mapView.isRotateCameraEnabled = false
        mapView.showsScale = true
        mapView.showsCompass = true

        let representation = MAUserLocationRepresentation()
        representation.showsAccuracyRing = false
        representation.showsHeadingIndicator = false
        mapView.update(representation)

        return mapView
    }

    func updateUIView(_ mapView: MAMapView, context: Context) {
        context.coordinator.parent = self
        updateRoute(in: mapView)
        context.coordinator.handleFocusUserLocationIfNeeded(in: mapView)
        context.coordinator.handleFocusTargetIfNeeded(in: mapView)
        context.coordinator.publishOverlayPoints(in: mapView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func updateRoute(in mapView: MAMapView) {
        mapView.removeOverlays(mapView.overlays)

        guard let route = route else { return }
        let coords = route.polyline.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        guard !coords.isEmpty else { return }

        var coordinates = coords
        let polyline = MAPolyline(coordinates: &coordinates, count: UInt(coords.count))
        mapView.add(polyline)
        mapView.showOverlays(
            [polyline],
            edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
            animated: true
        )
    }

    class Coordinator: NSObject, MAMapViewDelegate {
        var parent: AmapViewWrapper
        private var hasCenteredOnUserLocation = false
        private var lastHandledFocusToken: Int = -1
        private var lastHandledTargetToken: Int = -1

        init(_ parent: AmapViewWrapper) {
            self.parent = parent
        }

        func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
            guard let polyline = overlay as? MAPolyline else { return nil }
            let renderer = MAPolylineRenderer(polyline: polyline)
            renderer?.lineWidth = 8
            renderer?.lineJoinType = kMALineJoinRound
            renderer?.lineCapType = kMALineCapRound

            switch parent.transportMode {
            case .walking:
                renderer?.strokeColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.9)
                renderer?.lineDashType = kMALineDashTypeSquare
            case .cycling:
                renderer?.strokeColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.9)
            case .driving:
                renderer?.strokeImage = createGradientImage()
            }

            return renderer
        }

        private func createGradientImage() -> UIImage? {
            let size = CGSize(width: 100, height: 8)
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { context in
                let gradient = CGGradient(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: [
                        UIColor(red: 1.0, green: 0.0, blue: 0.71, alpha: 0.9).cgColor,
                        UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.55).cgColor
                    ] as CFArray,
                    locations: [0, 1]
                )!
                context.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: 0), options: [])
            }
        }

        func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
            guard updatingLocation,
                  let coordinate = userLocation.location?.coordinate,
                  coordinate.isValid else {
                return
            }
            if !hasCenteredOnUserLocation {
                hasCenteredOnUserLocation = true
                centerOnUserLocation(in: mapView, forceFollow: true)
            }
            publishOverlayPoints(in: mapView)
        }

        func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
            publishOverlayPoints(in: mapView)
        }

        func handleFocusUserLocationIfNeeded(in mapView: MAMapView) {
            guard parent.focusUserLocationToken != lastHandledFocusToken else { return }
            lastHandledFocusToken = parent.focusUserLocationToken
            centerOnUserLocation(in: mapView, forceFollow: true)
        }

        func handleFocusTargetIfNeeded(in mapView: MAMapView) {
            guard parent.focusTargetToken != lastHandledTargetToken else { return }
            lastHandledTargetToken = parent.focusTargetToken
            guard let coordinate = parent.focusTargetCoordinate, coordinate.isValid else { return }
            mapView.userTrackingMode = .none
            mapView.setCenter(coordinate, animated: true)
            if mapView.zoomLevel < 16 {
                mapView.setZoomLevel(16, animated: true)
            }
        }

        private func centerOnUserLocation(in mapView: MAMapView, forceFollow: Bool) {
            guard let coordinate = mapView.userLocation.location?.coordinate,
                  coordinate.isValid else {
                return
            }
            mapView.setCenter(coordinate, animated: true)
            if mapView.zoomLevel < 15 {
                mapView.setZoomLevel(15, animated: true)
            }
            if forceFollow {
                mapView.userTrackingMode = .follow
            }
        }
        
        func publishOverlayPoints(in mapView: MAMapView) {
            guard let onOverlayPointsChange = parent.onOverlayPointsChange else { return }
            var points: [String: CGPoint] = [:]
            for waypoint in parent.overlayWaypoints {
                let coordinate = parent.displayCoordinate?(waypoint) ?? waypoint.amapCoordinate
                guard coordinate.isValid else { continue }
                let point = mapView.convert(coordinate, toPointTo: mapView)
                points[waypoint.stableKey] = point
            }
            onOverlayPointsChange(points)
        }
    }
}

private extension CLLocationCoordinate2D {
    var isValid: Bool {
        abs(latitude) <= 90 && abs(longitude) <= 180
    }
}
