import XCTest

@testable import GeospatialSwift

class BoundingBoxTests: XCTestCase {
    private(set) var simpleBoundingBox: BoundingBox!
    
    private(set) var pointBoundingBox: BoundingBox!
    private(set) var horizontalBoundingBox: BoundingBox!
    private(set) var verticalBoundingBox: BoundingBox!

    private(set) var insideBoundingBox: BoundingBox!
    private(set) var horizontalOverlapBoundingBox: BoundingBox!
    private(set) var verticalOverlapBoundingBox: BoundingBox!
    private(set) var horizontalVerticalOverlapBoundingBox: BoundingBox!
    private(set) var noOverlapBoundingBox: BoundingBox!
    
    let boundingBoxMinimumAdjustment = 0.00005
    
    private var boundingCoordinatesHorizontalOverlap: BoundingCoordinates { return (minLongitude: simpleBoundingBox.minLongitude, minLatitude: simpleBoundingBox.minLatitude, maxLongitude: horizontalOverlapBoundingBox.maxLongitude, maxLatitude: simpleBoundingBox.maxLatitude) }
    
    private var boundingCoordinatesVerticalOverlap: BoundingCoordinates { return (minLongitude: simpleBoundingBox.minLongitude, minLatitude: simpleBoundingBox.minLatitude, maxLongitude: simpleBoundingBox.maxLongitude, maxLatitude: verticalOverlapBoundingBox.maxLatitude) }
    
    private var boundingCoordinatesCornerOverlap: BoundingCoordinates { return (minLongitude: simpleBoundingBox.minLongitude, minLatitude: simpleBoundingBox.minLatitude, maxLongitude: horizontalOverlapBoundingBox.maxLongitude, maxLatitude: verticalOverlapBoundingBox.maxLatitude) }
    
    private var boundingCoordinatesNoOverlap: BoundingCoordinates { return (minLongitude: simpleBoundingBox.minLongitude, minLatitude: simpleBoundingBox.minLatitude, maxLongitude: noOverlapBoundingBox.maxLongitude, maxLatitude: noOverlapBoundingBox.maxLatitude) }
    
    override func setUp() {
        super.setUp()
        
        simpleBoundingBox = BoundingBox(boundingCoordinates: (minLongitude: 0, minLatitude: 1, maxLongitude: 2, maxLatitude: 4))
        
        pointBoundingBox = BoundingBox(boundingCoordinates: (minLongitude: 0, minLatitude: 1, maxLongitude: 0, maxLatitude: 1))
        horizontalBoundingBox = BoundingBox(boundingCoordinates: (minLongitude: 0, minLatitude: 1, maxLongitude: 2, maxLatitude: 1))
        verticalBoundingBox = BoundingBox(boundingCoordinates: (minLongitude: 0, minLatitude: 1, maxLongitude: 0, maxLatitude: 3))
        
        // 0 - 2, 1 - 4
        // 1 - 1.5, 2 - 3
        insideBoundingBox = BoundingBox(boundingCoordinates: (minLongitude: 1, minLatitude: 2, maxLongitude: 1.5, maxLatitude: 3))
        // 1 - 2, 3 - 3
        horizontalOverlapBoundingBox = BoundingBox(boundingCoordinates: (minLongitude: 1, minLatitude: 2, maxLongitude: 3, maxLatitude: 3))
        verticalOverlapBoundingBox = BoundingBox(boundingCoordinates: (minLongitude: 1, minLatitude: 2, maxLongitude: 1.5, maxLatitude: 5))
        horizontalVerticalOverlapBoundingBox = BoundingBox(boundingCoordinates: (minLongitude: 1, minLatitude: 2, maxLongitude: 3, maxLatitude: 5))
        noOverlapBoundingBox = BoundingBox(boundingCoordinates: (minLongitude: 5, minLatitude: 6, maxLongitude: 7, maxLatitude: 9))
    }
    
    func testBoundingCoordinates() {
        XCTAssertEqual(simpleBoundingBox.points[0].longitude, simpleBoundingBox.minLongitude)
        XCTAssertEqual(simpleBoundingBox.points[0].latitude, simpleBoundingBox.minLatitude)
        XCTAssertEqual(simpleBoundingBox.points[2].longitude, simpleBoundingBox.maxLongitude)
        XCTAssertEqual(simpleBoundingBox.points[2].latitude, simpleBoundingBox.maxLatitude)
    }
    
    func testOverlaps_WhenSame_ThenTrue() {
        let overlaps = simpleBoundingBox.overlaps(boundingBox: simpleBoundingBox)
        
        XCTAssertEqual(overlaps, true)
    }
    
    func testOverlaps_WhenInside_ThenTrue() {
        let overlaps = simpleBoundingBox.overlaps(boundingBox: insideBoundingBox)
        
        XCTAssertEqual(overlaps, true)
    }
    
    func testOverlaps_WhenOutside_ThenTrue() {
        let overlaps = insideBoundingBox.overlaps(boundingBox: simpleBoundingBox)
        
        XCTAssertEqual(overlaps, true)
    }
    
    func testOverlaps_WhenHorizontalOverlap_ThenTrue() {
        let overlaps = simpleBoundingBox.overlaps(boundingBox: horizontalOverlapBoundingBox)
        
        XCTAssertEqual(overlaps, true)
    }
    
    func testOverlaps_WhenVerticalOverlap_ThenTrue() {
        let overlaps = simpleBoundingBox.overlaps(boundingBox: verticalOverlapBoundingBox)
        
        XCTAssertEqual(overlaps, true)
    }
    
    func testOverlaps_WhenHorizontalVerticalOverlap_ThenTrue() {
        let overlaps = simpleBoundingBox.overlaps(boundingBox: horizontalVerticalOverlapBoundingBox)
        
        XCTAssertEqual(overlaps, true)
    }
    
    func testOverlaps_WhenNoOverlap_ThenFalse() {
        let overlaps = simpleBoundingBox.overlaps(boundingBox: noOverlapBoundingBox)
        
        XCTAssertEqual(overlaps, false)
    }
    
    func testContains_WhenInside_ThenTrue() {
        let contains = simpleBoundingBox.contains(point: simpleBoundingBox.centroid)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_WhenOn_ThenTrue() {
        let contains = simpleBoundingBox.contains(point: SimplePoint(longitude: simpleBoundingBox.minLongitude, latitude: simpleBoundingBox.minLatitude))
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_WhenOutside_ThenFalse() {
        let contains = simpleBoundingBox.contains(point: SimplePoint(longitude: noOverlapBoundingBox.minLongitude, latitude: noOverlapBoundingBox.minLatitude))
        
        XCTAssertEqual(contains, false)
    }
    
    func testLongitudeDelta() {
        XCTAssertEqual(pointBoundingBox.longitudeDelta, 0, "longitudeDelta should be the difference in min and max longitude")
        XCTAssertEqual(horizontalBoundingBox.longitudeDelta, 2, "longitudeDelta should be the difference in min and max longitude")
        XCTAssertEqual(verticalBoundingBox.longitudeDelta, 0, "longitudeDelta should be the difference in min and max longitude")
        XCTAssertEqual(simpleBoundingBox.longitudeDelta, 2, "longitudeDelta should be the difference in min and max longitude")
    }
    
    func testLatitudeDelta() {
        XCTAssertEqual(pointBoundingBox.latitudeDelta, 0, "latitudeDelta should be the difference in min and max latitude")
        XCTAssertEqual(horizontalBoundingBox.latitudeDelta, 0, "latitudeDelta should be the difference in min and max latitude")
        XCTAssertEqual(verticalBoundingBox.latitudeDelta, 2, "latitudeDelta should be the difference in min and max latitude")
        XCTAssertEqual(simpleBoundingBox.latitudeDelta, 3, "latitudeDelta should be the difference in min and max latitude")
    }
    
    func testCentroid() {
        XCTAssertEqual(pointBoundingBox.centroid.longitude, 0, "centerCoordinate.longitude should be the center point of min and max longitude")
        XCTAssertEqual(pointBoundingBox.centroid.latitude, 1, "centerCoordinate.latitude should be the center point of min and max latitude")
        XCTAssertEqual(simpleBoundingBox.centroid.longitude, 1, "centerCoordinate.longitude should be the center point of min and max longitude")
        XCTAssertEqual(simpleBoundingBox.centroid.latitude, 2.5, "centerCoordinate.latitude should be the center point of min and max latitude")
    }
    
    func testPoints() {
        XCTAssertEqual(simpleBoundingBox.points.count, 4, "coordinates should have 4 points")
        XCTAssertEqual(simpleBoundingBox.points[0].longitude, simpleBoundingBox.minLongitude)
        XCTAssertEqual(simpleBoundingBox.points[0].latitude, simpleBoundingBox.minLatitude)
        XCTAssertEqual(simpleBoundingBox.points[1].longitude, simpleBoundingBox.minLongitude)
        XCTAssertEqual(simpleBoundingBox.points[1].latitude, simpleBoundingBox.maxLatitude)
        XCTAssertEqual(simpleBoundingBox.points[2].longitude, simpleBoundingBox.maxLongitude)
        XCTAssertEqual(simpleBoundingBox.points[2].latitude, simpleBoundingBox.maxLatitude)
        XCTAssertEqual(simpleBoundingBox.points[3].longitude, simpleBoundingBox.maxLongitude)
        XCTAssertEqual(simpleBoundingBox.points[3].latitude, simpleBoundingBox.minLatitude)
    }
    
    func testAdjustedBoundingBox_WhenMinAndMaxLongitudeAreEqual_ThenAdjust() {
        let verticalAdjustedBoundingBox = verticalBoundingBox.adjusted(minimumAdjustment: boundingBoxMinimumAdjustment)
        
        XCTAssertEqual(verticalAdjustedBoundingBox.minLongitude, verticalBoundingBox.minLongitude - boundingBoxMinimumAdjustment)
        XCTAssertEqual(verticalAdjustedBoundingBox.maxLongitude, verticalBoundingBox.maxLongitude + boundingBoxMinimumAdjustment)
    }
    
    func testAdjustedBoundingBox_WhenMinAndMaxLatitudeAreEqual_ThenAdjust() {
        let horizontalAdjustedBoundingBox = horizontalBoundingBox.adjusted(minimumAdjustment: boundingBoxMinimumAdjustment)
        
        XCTAssertEqual(horizontalAdjustedBoundingBox.minLatitude, horizontalBoundingBox.minLatitude - boundingBoxMinimumAdjustment)
        XCTAssertEqual(horizontalAdjustedBoundingBox.maxLatitude, horizontalBoundingBox.maxLatitude + boundingBoxMinimumAdjustment)
    }
    
    func testAdjustedBoundingBox_WhenMinAndMaxLongitudeAreDifferent_ThenNoAdjustment() {
        let horizontalAdjustedBoundingBox = horizontalBoundingBox.adjusted(minimumAdjustment: boundingBoxMinimumAdjustment)
        
        XCTAssertEqual(horizontalAdjustedBoundingBox.minLongitude, horizontalBoundingBox.minLongitude)
        XCTAssertEqual(horizontalAdjustedBoundingBox.maxLongitude, horizontalBoundingBox.maxLongitude)
    }
    
    func testAdjustedBoundingBox_WhenMinAndMaxLatitudeAreDifferent_ThenNoAdjustment() {
        let verticalAdjustedBoundingBox = verticalBoundingBox.adjusted(minimumAdjustment: boundingBoxMinimumAdjustment)
        
        XCTAssertEqual(verticalAdjustedBoundingBox.minLatitude, verticalBoundingBox.minLatitude)
        XCTAssertEqual(verticalAdjustedBoundingBox.maxLatitude, verticalBoundingBox.maxLatitude)
    }

    func testEqual() {
        XCTAssertEqual(simpleBoundingBox, simpleBoundingBox)
        XCTAssertEqual(horizontalBoundingBox, horizontalBoundingBox)
        XCTAssertEqual(verticalBoundingBox, verticalBoundingBox)
        XCTAssertEqual(pointBoundingBox, pointBoundingBox)
    }
    
    func testNotEqual() {
        XCTAssertNotEqual(horizontalBoundingBox, simpleBoundingBox)
        XCTAssertNotEqual(verticalBoundingBox, simpleBoundingBox)
        XCTAssertNotEqual(pointBoundingBox, simpleBoundingBox)
    }
    
    func testBest_WhenEmpty_ThenNil() {
        XCTAssertEqual(BoundingBox.best([]) as? BoundingBox, nil)
    }
    
    func testBest_WhenOnlySelf_ThenSelf() {
        XCTAssertEqual(BoundingBox.best([simpleBoundingBox]) as? BoundingBox, simpleBoundingBox)
    }
    
    func testBest_WhenSame_ThenSelf() {
        XCTAssertEqual(BoundingBox.best([simpleBoundingBox, simpleBoundingBox]) as? BoundingBox, simpleBoundingBox)
    }
    
    func testBest_WhenInside_ThenSelf() {
        XCTAssertEqual(BoundingBox.best([simpleBoundingBox, insideBoundingBox]) as? BoundingBox, simpleBoundingBox)
    }
    
    func testBest_WhenHorizontalOverlap_ThenBest() {
        let expectedBoundingBox = BoundingBox(boundingCoordinates: boundingCoordinatesHorizontalOverlap)
        
        XCTAssertEqual(BoundingBox.best([simpleBoundingBox, horizontalOverlapBoundingBox]) as? BoundingBox, expectedBoundingBox)
    }
    
    func testBest_WhenVerticalOverlap_ThenBest() {
        let expectedBoundingBox = BoundingBox(boundingCoordinates: boundingCoordinatesVerticalOverlap)
        
        XCTAssertEqual(BoundingBox.best([simpleBoundingBox, verticalOverlapBoundingBox]) as? BoundingBox, expectedBoundingBox)
    }
    
    func testBest_WhenHorizontalVerticalOverlap_ThenBest() {
        let expectedBoundingBox = BoundingBox(boundingCoordinates: boundingCoordinatesCornerOverlap)
        
        XCTAssertEqual(BoundingBox.best([simpleBoundingBox, horizontalVerticalOverlapBoundingBox]) as? BoundingBox, expectedBoundingBox)
    }
    
    func testBest_Multiple_ThenBest() {
        let expectedBoundingBox = BoundingBox(boundingCoordinates: boundingCoordinatesCornerOverlap)
        
        XCTAssertEqual(BoundingBox.best([simpleBoundingBox, pointBoundingBox, horizontalOverlapBoundingBox, verticalOverlapBoundingBox]) as? BoundingBox, expectedBoundingBox)
    }
    
    func testBest_WhenNoOverlap_ThenBest() {
        let expectedBoundingBox = BoundingBox(boundingCoordinates: boundingCoordinatesNoOverlap)
        
        XCTAssertEqual(BoundingBox.best([simpleBoundingBox, noOverlapBoundingBox]) as? BoundingBox, expectedBoundingBox)
    }
}
