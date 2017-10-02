//
//  TimePoint.swift
//  EonilStateSeries
//
//  Created by Hoon H. on 2017/10/02.
//
//

///
/// A series of globally unique and ordered key.
///
/// - Resolution is near infinite. You can spawn
///   `TimePoint` infinitely as long as memory
///   allows.
/// - To be global, there's only one series defines.
/// - To save space, the series will be compressed
///   by popping out unused keys.
/// - To save numeric space, the ordering number
///   of each keys can be renewed.
///
final class TimePoint: Comparable, Hashable, CustomDebugStringConvertible {
    typealias OrderNumber = UInt64
    unowned let containerSegment: TimeSegment
    let orderInSegment: OrderNumber
    fileprivate init(order: OrderNumber, in container: TimeSegment) {
        orderInSegment = order
        containerSegment = container
    }
    deinit {
        containerSegment.pop(self)
    }
    var segmentIndexInLine: Int {
        return containerSegment.indexInLine
    }
    var hashValue: Int {
        // `segmentIndexInLine` is unstable.
        // Do not use it.
        return orderInSegment.hashValue
    }
    static func == (_ a: TimePoint, _ b: TimePoint) -> Bool {
        return a.orderInSegment == b.orderInSegment && a.segmentIndexInLine == b.segmentIndexInLine
    }
    static func < (_ a: TimePoint, _ b: TimePoint) -> Bool {
        guard a.segmentIndexInLine == b.segmentIndexInLine else { return a.segmentIndexInLine < b.segmentIndexInLine }
        return a.orderInSegment < b.orderInSegment
    }

    var debugDescription: String {
        let id = ObjectIdentifier(self)
        return """
            TimePoint(identity: \(id.makeAddress()), segment: \(containerSegment), order: \(orderInSegment))
        """
    }
}

///
/// A segment does not actually keep list of points.
/// A segment keeps only point count and order seed number for new points.
///
final class TimeSegment {
    unowned let containerTimeline: TimeLine
    fileprivate var indexInLine: Int
    private var orderSeed = TimePoint.OrderNumber(0)
    private(set) var pointCount = 0
    fileprivate init(in container: TimeLine, at index: Int) {
        containerTimeline = container
        indexInLine = index
    }
    fileprivate func pop(_ p: TimePoint) {
        pointCount -= 1
        containerTimeline.compactIfNeeded()
    }
    @discardableResult
    func append() -> TimePoint {
        let p = TimePoint(order: orderSeed, in: self)
        pointCount += 1
        orderSeed += 1
        return p
    }
}

///
/// Defines a conceptually dense sequence of time-points.
///
/// Basically, time-point is defined (segment ID + point ID).
/// Segment ID is mutable, and floating number. It just defines
/// relative order between segments.
/// Point ID is immutable, and fixed number. It defines relative
/// order in a segment.
///
/// This class fill a segment, and if a segment becomes full,
/// it appends a new segment.
/// If all points in a segment has been removed, the segment will
/// be removed from segment-list, and address offset number of all
/// the other segments will be updated. This is O(n) where `n` is
/// number of segments.
///
/// You don't need segment re-indexing as long as you have some ID
/// space available in last segment.
///
/// - A new point can be appended only to the end.
/// - Any point can be removed at any time.
///   Just remove all reference to point to remove them.
///
/// - Note: Main-thread only for now.
///         This can be better later.
///
final class TimeLine {
    private let maxSegmentCount: Int
    private let maxPointCountInSegment: Int
    ///
    /// Space is segmented to reduce needs for compacting dramatically.
    ///
    private(set) var segments = [TimeSegment]()
    ///
    /// Exposed interally to allow testing.
    ///
    init(maxSegmentCount: Int = 16, maxPointCountInSegment: Int = .max) {
        assertMainThread()
        self.maxSegmentCount = maxSegmentCount
        self.maxPointCountInSegment = maxPointCountInSegment
    }
    @discardableResult
    func append() -> TimePoint {
        assertMainThread()
        return getSegment().append()
    }
    fileprivate func compactIfNeeded() {
        assertMainThread()
        guard segments.count >= maxSegmentCount else { return }
        segments = segments.filter({ $0.pointCount > 0 })
        for i in 0..<segments.count {
            segments[i].indexInLine = i
        }
    }
    private func getSegment() -> TimeSegment {
        assertMainThread()
        guard let last = segments.last else { return appendSegment() }
        guard last.pointCount < maxPointCountInSegment else { return appendSegment() }
        return last
    }
    private func appendSegment() -> TimeSegment {
        assertMainThread()
        precondition(segments.count < maxSegmentCount, "Exceeding maximum segment count limit: \(maxSegmentCount)")
        let s = TimeSegment(in: self, at: segments.count)
        segments.append(s)
        return s
    }

    static let shared = TimeLine()
    static func spawn() -> TimePoint {
        assertMainThread()
        return shared.append()
    }
}
