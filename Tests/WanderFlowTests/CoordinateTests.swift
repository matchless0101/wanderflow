import XCTest
@testable import WanderFlow
import CoreLocation

final class CoordinateTests: XCTestCase {
    
    func testWgs84ToGcj02() {
        // Test with a known coordinate in China (e.g., Tiananmen Square)
        let wgs84 = CLLocationCoordinate2D(latitude: 39.9087, longitude: 116.3975)
        let gcj02 = CoordinateTransform.wgs84ToGcj02(wgs84)
        
        // Expected shift is roughly a few hundred meters
        XCTAssertNotEqual(wgs84.latitude, gcj02.latitude)
        XCTAssertNotEqual(wgs84.longitude, gcj02.longitude)
        
        // Test outside China (should be same)
        let outCoords = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060) // NYC
        let gcjOut = CoordinateTransform.wgs84ToGcj02(outCoords)
        
        XCTAssertEqual(outCoords.latitude, gcjOut.latitude)
        XCTAssertEqual(outCoords.longitude, gcjOut.longitude)
    }
    
    func testGcj02ToWgs84() {
        let original = CLLocationCoordinate2D(latitude: 39.9087, longitude: 116.3975)
        let gcj02 = CoordinateTransform.wgs84ToGcj02(original)
        let reverted = CoordinateTransform.gcj02ToWgs84(gcj02)
        
        // Should be very close to original
        XCTAssertEqual(original.latitude, reverted.latitude, accuracy: 0.00001)
        XCTAssertEqual(original.longitude, reverted.longitude, accuracy: 0.00001)
    }
}
