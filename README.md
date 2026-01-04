# DosingSystems

A Swift library for engineering calculations in high-speed industrial dosing systems.

The library provides:
- Strongly typed physical units (Length, Time, Speed, Volume, FlowRate)
- Safe and readable dosing mathematics
- Support for metric and US units
- Deterministic, side-effect-free calculations

Designed for:
- High-speed filling and dosing machines
- Transfer star/ conveyour based systems
- Valve-based dosing with linear characteristics

---

## Features

- Type-safe units (mm, ms, mL, mm/s, mL/ms)
- Compile-time protection against unit mix-ups
- Clear domain-specific API
- No runtime dependencies

---

## Example
```
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


#```# Philosophy

This library intentionally avoids implicit unit conversions and untyped numeric parameters.
All calculations are expressed in physical terms, mirroring real-world machine behavior.

## Status
This project is under active development.

## License
MIT
