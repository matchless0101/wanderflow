# Changelog

## [Unreleased]

### Added
- **Amap SDK Integration**: Added `AMap3DMap`, `AMapSearch`, `AMapNavi` (v9.7.0) and `AMapLocation` (v2.x) via CocoaPods.
- **AmapManager**: Centralized manager for Amap services.
- **Custom Markers**: `CustomAnnotationView` with sequence number and breathing animation.
- **Custom Callouts**: `CustomCalloutView` with blur effect and details button.
- **Gradient Route**: Route rendering with gradient colors (#FF00B4FF to #FF00FF8C).
- **Coordinate Transformation**: `CoordinateTransform` utility for WGS84 <-> GCJ02 <-> BD09 conversion.

### Changed
- **MapView**: Replaced `MapContainerView` (MapKit) with `AmapViewWrapper` (MAMapKit).
- **Route Planning**: Updated `AIService` to use `AMapNaviDriveManager` for route calculation instead of Web API.
- **Geocoding**: Replaced `CLGeocoder` with `AMapSearchAPI` in `Itinerary` model.
- **Coordinate System**: AI-generated points now default to WGS84 and are converted to GCJ02 for display.

### Removed
- **MapKit Dependencies**: Removed `MKMapView`, `MKPolyline`, `MKAnnotation` usages from main map view.
- **CLGeocoder**: Removed CoreLocation geocoding logic.
