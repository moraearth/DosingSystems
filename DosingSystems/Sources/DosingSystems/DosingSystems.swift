public struct Length: Equatable, Comparable, Sendable {
    public let mm: Double
    private init(mm: Double) { self.mm = mm }
    
    public static func millimeter(_ value: Double) -> Length { .init(mm: value) }
    public static func inch(_ value: Double) -> Length { .init(mm: value * 25.4) }
    
    public var inMM: Double { mm }
    public var inInch: Double { mm / 25.4 }
    
    public static func < (lhs: Length, rhs: Length) -> Bool {
        lhs.mm < rhs.mm
    }
    public static func + (lhs: Length, rhs: Length) -> Length {
        .millimeter(lhs.mm + rhs.mm)
    }
    public static func - (lhs: Length, rhs: Length) -> Length {
        .millimeter(lhs.mm - rhs.mm)
    }
    public static func * (lhs: Length, rhs: Double) -> Length {
        .millimeter(lhs.mm * rhs)
    }
    public static func * (lhs: Double, rhs: Length) -> Length {
        .millimeter(lhs * rhs.mm)
    }
    public static func / (lhs: Length, rhs: Double) -> Length {
        .millimeter(lhs.mm / rhs)
    }
}

public struct Time: Equatable, Comparable, Sendable {
    public let ms: Double
    private init(ms: Double) { self.ms = ms }
    
    public static func millisecond(_ value: Double) -> Time { .init(ms: value) }
    public static func second(_ value: Double) -> Time { .init(ms: value * 1000.0) }
    
    public var inMS: Double { ms }
    public var inSecond: Double { ms / 1000.0 }
    
    public static func < (lhs: Time, rhs: Time) -> Bool {
        lhs.ms < rhs.ms
    }
    public static func + (lhs: Time, rhs: Time) -> Time {
        .millisecond(lhs.ms + rhs.ms)
    }
    public static func - (lhs: Time, rhs: Time) -> Time {
        .millisecond(lhs.ms - rhs.ms)
    }
    public static func * (lhs: Time, rhs: Double) -> Time {
        .millisecond(lhs.ms * rhs)
    }
    public static func * (lhs: Double, rhs: Time) -> Time {
        .millisecond(lhs * rhs.ms)
    }
    public static func / (lhs: Time, rhs: Double) -> Time {
        .millisecond(lhs.ms / rhs)
    }
}

public struct Speed: Equatable, Comparable, Sendable {
    public let mmPerS: Double
    private init (mmPerS: Double) { self.mmPerS = mmPerS }
    
    public static func millimeterPerSecond(_ value: Double) -> Speed {
        .init(mmPerS: value)
    }
    
    public var inMMPerS: Double { mmPerS }
    
    public static func < (lhs: Speed, rhs: Speed) -> Bool {
        lhs.mmPerS < rhs.mmPerS
    }
    public static func * (lhs: Speed, rhs: Time) -> Length {
        .millimeter(lhs.mmPerS * rhs.inSecond)
    }
    public static func * (lhs: Time, rhs: Speed) -> Length {
        .millimeter(rhs.mmPerS * lhs.inSecond)
    }
    public static func / (lhs: Length, rhs: Speed) -> Time {
        .second(lhs.mm / rhs.mmPerS)
    }
}

public struct Volume: Equatable, Comparable, Sendable {
    public let mL: Double
    private init(mL: Double) {self.mL = mL }
    
    public static func milliliter(_ value: Double) -> Volume {
        .init(mL: value)
    }
    public static func fluidOunceUS(_ value: Double) -> Volume {
        .init(mL: value * 29.5735)
    }
    
    public var inML: Double { mL }
    public var inFluidOunceUS: Double { mL / 29.5735 }
    
    public static func < (lhs: Volume, rhs: Volume) -> Bool {
        lhs.mL < rhs.mL
    }
    public static func + (lhs: Volume, rhs: Volume) -> Volume {
        .milliliter(lhs.mL + rhs.mL)
    }
    public static  func - (lhs: Volume, rhs: Volume) -> Volume {
        .milliliter(lhs.mL - rhs.mL)
    }
    public static func / (lhs: Volume, rhs: Volume) -> Double {
        lhs.mL / rhs.mL
    }
}

public struct FlowRate: Equatable, Comparable, Sendable {
    public let mLPerMS: Double
    private init(mLPerMS: Double) { self.mLPerMS = mLPerMS }
    
    public static func milliliterPerMillisecond(_ value: Double) -> FlowRate {
        .init(mLPerMS: value)
    }
    
    public var inMLPerMS: Double { mLPerMS }
    public var inMLPerS: Double { mLPerMS * 1000.0 }
    
    public static func < (lhs: FlowRate, rhs: FlowRate) -> Bool {
        lhs.mLPerMS < rhs.mLPerMS
    }
    public static func * (lhs: FlowRate, rhs: Time) -> Volume {
        .milliliter(lhs.mLPerMS * rhs.ms)
    }
    public static func * (lhs: Time, rhs: FlowRate) -> Volume {
        .milliliter(rhs.mLPerMS * lhs.ms)
    }
    public static func / (lhs: Volume, rhs: FlowRate) -> Time {
        .millisecond(lhs.mL / rhs.mLPerMS)
    }
}

public struct DosingMath {
    
    private static let secPerHour = 3600.0
    
    // UPH + pitch -> Speed
    public static func computeLineSpeed(
        fromUPH uph: Double,
        pitch: Length
    ) -> Speed {
        return .millimeterPerSecond(uph * pitch.mm / secPerHour)
    }
    
    // UPH + star radius + pockets -> Speed
    public static func computeLineSpeed(
        fromUPH uph: Double,
        transferStarRadius: Length,
        numberOfPockets: Int
    ) -> Speed {
        let circumferenceMM = 2.0 * Double.pi * transferStarRadius.mm
        return .millimeterPerSecond(uph * circumferenceMM / Double(numberOfPockets) / secPerHour )
    }
    
    // UPH + star circumference + pockets -> Speed
    public static func computeLineSpeed(
        fromUPH uph: Double,
        transferStarCircumference: Length,
        numberOfPockets: Int
    ) -> Speed {
        return .millimeterPerSecond(uph * transferStarCircumference.mm / Double(numberOfPockets) / secPerHour)
    }
    
    // opening / speed -> Time
    public static func computeMaxDwellTime(
        containerOpening: Length,
        lineSpeed: Speed,
        openingSafetyFactor: Double = 1.0
    ) -> Time {
        let t = (containerOpening * openingSafetyFactor) / lineSpeed // -> Time (sec)
        return .millisecond(t.inSecond * 1000.0)
    }
    
    // volume = gain(mL/ms) * trigger(ms) + offset(mL)
    public static func computeValveDosingVolume(
        fromValveTriggerTime triggerTime: Time,
        valveGain: FlowRate,
        valveOffset: Volume
    ) -> Volume {
        return .milliliter(valveGain.mLPerMS * triggerTime.ms + valveOffset.mL)
    }
    
    // trigger(ms) = (volume - offset) / gain
    public static func computeValveTriggerTime(
        fromValveDosingVolume dosingVolume: Volume,
        valveGain: FlowRate,
        valveOffset: Volume
    ) -> Time {
        return .millisecond((dosingVolume.mL - valveOffset.mL) / valveGain.mLPerMS)
    }
    
    public static func computeRequiredValveCount(
        fromTargetDosingVolume targetVolume: Volume,
        maxVolumePerValve: Volume
    ) -> Int {
        return Int((targetVolume.mL / maxVolumePerValve.mL).rounded(.up))
    }
}

