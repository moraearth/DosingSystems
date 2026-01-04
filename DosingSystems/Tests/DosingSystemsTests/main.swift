//
//  main.swift
//  TestDosingSystemsPacket
//
//  Created by QbitFurry on 03.01.26.
//

import DosingSystems
import Foundation

let uph = 32_000.0

let pitch = Length.millimeter(108)
let opening = Length.millimeter(21)

// Compute Line Speed
let speed = DosingMath.computeLineSpeed(fromUPH: uph, pitch: pitch)

// Compute Dwell Time
// = the time which a moving container moves/remains under the dosing valve and is
// available for dispensing
let dwell = DosingMath.computeMaxDwellTime(
    containerOpening: opening,
    lineSpeed: speed,
    openingSafetyFactor: 0.75
)

// Valve's Curve
let valveOffset = Volume.milliliter(0.01335)
let valveGain = FlowRate.milliliterPerMillisecond(0.07867)

// Compute Maximal Dosing Volume
// = dispensed per container
let vol = DosingMath.computeValveDosingVolume(
    fromValveTriggerTime: dwell - Time.millisecond(10),
    valveGain: valveGain,
    valveOffset: valveOffset
)

let maxTargetVolume = Volume.milliliter(1.8)
let requiredValveCount = DosingMath.computeRequiredValveCount(
    fromTargetDosingVolume: maxTargetVolume,
    maxVolumePerValve: vol
)

print(String(repeating:"-", count: 40))

print(
    String(format: "Line Speed is %.2f mm/s.", speed.inMMPerS)
)

print(
    String(format: "Dwell Time is %.2f ms.", dwell.inMS)
)

print(
    String(format: "Maximal Dosing Volume is %.2f ml.", vol.inML)
)

print(
    String(format: "Required System Number of Valves: %d ", requiredValveCount)
)

print(String(repeating:"-", count: 40))


