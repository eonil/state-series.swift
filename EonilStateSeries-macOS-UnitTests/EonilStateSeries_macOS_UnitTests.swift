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
    func testRawKeyOrderValues() {
        typealias SS = StateSeries<Int>
        var s1 = SS()
        for i in 0..<(SS.defaultMaxUnavailableKeySpaceCount + 2) {
            s1.append(i * 100)
            let pid = s1.points.last!.id
            XCTAssertEqual(UInt64(pid.rawKey.order), UInt64(i + 1))
        }
    }
    func testRawKeyCompaction() {
        typealias SS = StateSeries<Int>
        var s1 = SS()
        for i in 0..<(SS.defaultMaxUnavailableKeySpaceCount + 2) {
            s1.append(i * 100)
            if s1.points.count > 16 {
                s1.removeFirst()
            }
            let pid = s1.points.last!.id
            if pid.rawKey.length < SS.defaultMaxUnavailableKeySpaceCount {
                XCTAssertEqual(UInt64(pid.rawKey.order), UInt64(i + 1))
            }
            else {
                XCTAssertEqual(UInt64(pid.rawKey.order), UInt64(i + 1 - SS.defaultMaxUnavailableKeySpaceCount))
            }
        }
    }
//    func testCompact() {
//        typealias SS = StateSeries<Int>
//        var s1 = SS()
//        s1.append(contentsOf: [111, 222, 333])
//        let id3 = s1.points[2].id
//        s1.removeFirst(2)
//        s1.compact()
//        XCTAssertEqual(s1.points.count, 1)
//        XCTAssertEqual(s1.points[0].id, id3)
//        XCTAssertEqual(s1.points[0].state, 333)
//    }
//    func testCompactAndAppend() {
//        typealias SS = StateSeries<Int>
//        var s1 = SS()
//        s1.append(contentsOf: [111, 222, 333])
//        let id3 = s1.points[2].id
//        s1.removeFirst(2)
//        XCTAssertEqual(s1.baseIndex, 2)
//        s1.compact()
//        XCTAssertEqual(s1.baseIndex, 0)
//        XCTAssertEqual(s1.points.count, 1)
//        XCTAssertEqual(s1.points[0].id, id3)
//        XCTAssertEqual(s1.points[0].state, 333)
//        s1.append(444)
//        s1.append(555)
//        XCTAssertEqual(s1.baseIndex, 0)
//        XCTAssertEqual(s1.points.count, 3)
//        XCTAssertLessThan(s1.points[0].id, s1.points[1].id)
//        XCTAssertLessThan(s1.points[0].id, s1.points[2].id)
//        XCTAssertLessThan(s1.points[1].id, s1.points[2].id)
//        XCTAssertEqual(Array(s1.points.sorted(by: { a, b in a < b }).map({ $0.state })), [333, 444, 555])
//    }
}
