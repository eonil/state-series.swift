//
//  StateSeriesWatchdog.swift
//  EonilStateSeries
//
//  Created by Hoon H. on 2017/10/02.
//
//

///
/// Reports suspicious situations.
///
/// This library can detect some bug-like situations.
/// Such situations will be reported via function set
/// to shared `delegate` property. You can set your own
/// function to receive a warning report.
///
public enum StateSeriesWatchDog {
    ///
    /// This library never touch this property.
    ///
    public static var delegate: ((Issue) -> Void)?

    static func cast(_ issue: Issue) {
        guard let delegate = delegate else { assert(false, "StateSeriesWatchDog Warning: \(issue)") }
        delegate(issue)
    }

    public enum Issue {
        ///
        /// Casted when number of dead point IDs are over 128.
        ///
        /// "Dead" point ID is a point ID which is alive but
        /// not referenced by points in a series. This happens
        /// if user copied and stored many point IDs on somewhere
        /// else, and removed many points from series.
        ///
        /// Though this is very likely to be a bug in user progrem,
        /// but still can be a normal situation up to user program's
        /// usage pattern. If you intentionally stored old point IDs,
        /// you can ignore this warning safely.
        ///
        case tooManyDeadPointIDInstancesAreAlive
    }
}
