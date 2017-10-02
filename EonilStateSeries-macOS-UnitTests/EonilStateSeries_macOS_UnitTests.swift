//
//  EonilStateSeries_macOS_UnitTests.swift
//  EonilStateSeries-macOS-UnitTests
//
//  Created by Hoon H. on 2017/10/01.
//

import XCTest
@testable import EonilStateSeries

class EonilStateSeries_macOS_UnitTests: XCTestCase {
    func testAppendSingle() {
        typealias SS = StateSeries<Int>
        var s1 = SS()
        s1.append(111)
        let ps = s1.points
        XCTAssertEqual(ps.count, 1)
        XCTAssertEqual(ps[0].state, 111)
    }
    func testAppendMultiple() {
        typealias SS = StateSeries<Int>
        var s1 = SS()
        s1.append(contentsOf: [111, 222, 333])
        let ps = s1.points
        XCTAssertEqual(ps.count, 3)
        XCTAssertEqual(ps[0].state, 111)
        XCTAssertEqual(ps[1].state, 222)
        XCTAssertEqual(ps[2].state, 333)
        XCTAssertFalse(ps[0].id == ps[1].id)
        XCTAssertFalse(ps[1].id == ps[2].id)
        XCTAssertFalse(ps[2].id == ps[0].id)
        XCTAssertLessThan(ps[0].id, ps[1].id)
        XCTAssertLessThan(ps[1].id, ps[2].id)
        XCTAssertLessThan(ps[0].id, ps[2].id)
        XCTAssertGreaterThan(ps[2].id, ps[0].id)
        XCTAssertGreaterThan(ps[2].id, ps[1].id)
        XCTAssertGreaterThan(ps[1].id, ps[0].id)
    }
    func testVersionEquality() {
        typealias SS = StateSeries<Int>
        var s1 = SS()
        s1.append(111)
        XCTAssertEqual(s1.points.count, 1)
        XCTAssertEqual(s1.points[0].state, 111)
        var s2 = s1
        XCTAssertEqual(s1.points.count, 1)
        XCTAssertEqual(s1.points[0].state, 111)
        XCTAssertEqual(s2.points.count, 1)
        XCTAssertEqual(s2.points[0].state, 111)
        XCTAssertTrue(s1.points.last!.id == s2.points.last!.id)
        s2.append(222)
        XCTAssertEqual(s1.points.count, 1)
        XCTAssertEqual(s1.points[0].state, 111)
        XCTAssertEqual(s2.points.count, 2)
        XCTAssertEqual(s2.points[0].state, 111)
        XCTAssertEqual(s2.points[1].state, 222)
        XCTAssertFalse(s1.points.last!.id == s2.points.last!.id)
    }
    func testTimeLineSegmentation() {
        let t = TimeLine(maxSegmentCount: 2, maxPointCountInSegment: 4)
        var ps = [TimePoint]()
        for _ in 0..<8 {
            ps.append(t.append())
        }
        XCTAssert(t.segments.count == 2)
        XCTAssert(t.segments[0].pointCount == 4)
        XCTAssert(t.segments[1].pointCount == 4)
        XCTAssertEqual(ps.sorted(), ps)
        XCTAssertEqual([ps[3], ps[2], ps[0], ps[5]].sorted(), [ps[0], ps[2], ps[3], ps[5]])
    }
    func testTimeLineCompaction() {
        let t = TimeLine(maxSegmentCount: 2, maxPointCountInSegment: 4)
        var ps = [TimePoint]()
        for _ in 0..<8 {
            ps.append(t.append())
        }
        ps.removeAll()
        XCTAssert(t.segments.count == 1)
        XCTAssert(t.segments[0].pointCount == 0)
    }
}
