////
////  Impl2.swift
////  EonilStateSeries
////
////  Created by Hoon H. on 2017/10/01.
////
////
//
/////
///// A series of state-point.
/////
///// This is analogue of time-series data.
///// Also known as state-stream.
///// - Stream is incremental only.
///// - States are ordered by time of appending.
///// - Once appended state never changes. (immutable)
///// - Old data can partially be purged on demand.
/////
///// Index Offset
///// ------------
///// Some front points can be removed on demand. As we use index value
///// as order of point, it needs reassigning of new index of all points,
///// and this is inefficient. To avoid reassigning (O(n)) every time,
///// we just store offset to index until reassigning occurs.
/////
///// Notice that reassigning will happen eventually. Index offset does
///// not eliminate need for reassigning, but just reduces occurrence of
///// reassigning.
/////
///// Implementation is done by storing `baseIndex`. Index for point order
///// calculation must be obtainbed by `points.count + baseIndex`.
/////
//final class SSImpl<T>: CustomDebugStringConvertible {
//    typealias Point = PImpl<T>
//    private(set) var points = [Point]()                     //< See class documentation.
//    private let sharing = SSImplPImplMutableSharingBox()    //< See class documentation.
//    private(set) var baseIndex: Int {
//        get { return sharing.baseIndex }
//        set { sharing.baseIndex = newValue }
//    }
//    ///
//    /// Always O(n) because sharing box need to be reassigned
//    /// for all each `PImpl`s.
//    ///
//    func clone() -> SSImpl {
//        let new = SSImpl()
//        for p in points {
//            new.appendPoint(p.state)
//        }
//        return new
//    }
//    @discardableResult
//    func appendPoint(_ state: T) -> Point {
//        let idx = baseIndex + points.count
//        let p = Point(state, idx, sharing)
//        points.append(p)
//        return p
//    }
//    func removeFirstPoints(_ n: Int) {
//        baseIndex += n
//        points.removeFirst(n)
//    }
//    func compactKeySpace() {
//        baseIndex = 0
//        for i in 0..<points.count {
//            let p = points[i]
//            p.offsetFromBaseIndex = i
//        }
//    }
//
//    var debugDescription: String {
//        return """
//        StateSeries(
//            version: \(ObjectIdentifier(self).makeAddress()),
//            sharing: \(ObjectIdentifier(sharing).makeAddress()),
//            base: \(baseIndex),
//            points: \(points.debugDescription))
//        """
//    }
//}
/////
///// This box has been invented to avoid cycle-referece issue
///// if `SSImpl` and `PImpl` reference each other directly.
/////
//final class SSImplPImplMutableSharingBox {
//    ///
//    /// Base-index has been shared between `SSImpl` and `PImpl`.
//    /// As only `SSImpl` can modify the shared `baseIndex`,
//    /// it's safe to share. No one modifies base-index after
//    /// `SSImpl` died.
//    ///
//    var baseIndex = 0
//}
//
//
/////
///// Two `PImpl`s are equal if their contents (relative position in
///// a series) are equal.
/////
//final class PImpl<T>: Comparable, CustomDebugStringConvertible {
//    let state: T
//    fileprivate(set) var offsetFromBaseIndex: Int
//    private let sharing: SSImplPImplMutableSharingBox
//    init(_ s: T, _ i: Int, _ b: SSImplPImplMutableSharingBox) {
//        state = s
//        offsetFromBaseIndex = i
//        sharing = b
//    }
//    var index: Int {
//        return sharing.baseIndex + offsetFromBaseIndex
//    }
//    static func == (_ a: PImpl, _ b: PImpl) -> Bool {
//        return a.index == b.index
//    }
//    static func < (_ a: PImpl, _ b: PImpl) -> Bool {
//        return a.index < b.index
//    }
//    var debugDescription: String {
//        let soid = ObjectIdentifier(sharing).makeAddress()
//        return "PointID(offset: \(offsetFromBaseIndex), sharing: \(soid), base: \(sharing.baseIndex))"
//    }
//}
//
