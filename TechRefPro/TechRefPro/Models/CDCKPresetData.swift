//
//  CDCKPresetData.swift
//  TechRefPro
//
//  Built-in reference data seeded on first launch. Values are typical
//  engineering reference figures for field use and are stored locally.
//

import Foundation

/// Factory for the bundled preset reference data.
enum CDCKPresetData {

    // MARK: Cable ampacity (≥ 20 rows, copper & aluminum)

    static func cables() -> [CDCKCableEntry] {
        // Cross-section : (copper 70°C, copper 90°C, aluminum 90°C) typical ampacity in conduit.
        let rows: [(Double, Double, Double, Double)] = [
            (1.0,   13,  15,   0),
            (1.5,   16,  19,   0),
            (2.5,   22,  26,   0),
            (4.0,   30,  35,  27),
            (6.0,   38,  46,  36),
            (10.0,  52,  63,  49),
            (16.0,  69,  85,  66),
            (25.0,  90, 112,  87),
            (35.0, 111, 138, 107),
            (50.0, 133, 168, 130),
            (70.0, 168, 213, 165),
            (95.0, 201, 258, 200),
            (120.0,232, 299, 232),
            (150.0,258, 344, 268),
            (185.0,294, 392, 305),
            (240.0,344, 461, 360)
        ]
        var entries: [CDCKCableEntry] = []
        for r in rows {
            entries.append(CDCKCableEntry(conductorMaterial: "Copper",
                                          crossSectionMM2: r.0,
                                          ampacityA: r.1,
                                          insulationTemp: 70,
                                          installationMethod: "In conduit"))
            entries.append(CDCKCableEntry(conductorMaterial: "Copper",
                                          crossSectionMM2: r.0,
                                          ampacityA: r.2,
                                          insulationTemp: 90,
                                          installationMethod: "In conduit"))
            if r.3 > 0 {
                entries.append(CDCKCableEntry(conductorMaterial: "Aluminum",
                                              crossSectionMM2: r.0,
                                              ampacityA: r.3,
                                              insulationTemp: 90,
                                              installationMethod: "In conduit"))
            }
        }
        return entries
    }

    // MARK: Wire gauge (AWG 18 → 4/0)

    static func wireGauges() -> [CDCKWireGauge] {
        // (AWG, mm², typical max amps at 60°C chassis-style reference)
        let rows: [(String, Double, Double)] = [
            ("18",  0.823,  10),
            ("16",  1.31,   13),
            ("14",  2.08,   20),
            ("12",  3.31,   25),
            ("10",  5.26,   35),
            ("8",   8.37,   50),
            ("6",  13.30,   65),
            ("4",  21.15,   85),
            ("3",  26.67,  100),
            ("2",  33.62,  115),
            ("1",  42.41,  130),
            ("1/0",53.49,  150),
            ("2/0",67.43,  175),
            ("3/0",85.01,  200),
            ("4/0",107.2,  230)
        ]
        return rows.map { CDCKWireGauge(awg: $0.0, mm2: $0.1, maxAmps: $0.2) }
    }

    // MARK: Breaker / contactor selection

    static func breakers() -> [CDCKBreakerSpec] {
        let rows: [(Int, Int, String, Double, String)] = [
            (6,   1, "B", 6,  "Lighting circuits"),
            (10,  1, "B", 6,  "General socket outlets"),
            (16,  1, "C", 6,  "Socket / small motor"),
            (20,  1, "C", 6,  "Kitchen / appliance"),
            (25,  2, "C", 10, "Water heater / AC"),
            (32,  2, "C", 10, "Cooker / EV charger"),
            (40,  3, "C", 10, "Sub-distribution feed"),
            (50,  3, "C", 10, "Small motor feeder"),
            (63,  3, "D", 10, "Motor with high inrush"),
            (80,  3, "D", 15, "Motor / transformer"),
            (100, 3, "D", 15, "Main distribution"),
            (125, 3, "D", 25, "Main incomer"),
            (160, 3, "D", 25, "Industrial feeder"),
            (200, 3, "D", 36, "Large industrial feeder")
        ]
        return rows.map {
            CDCKBreakerSpec(ratedCurrentA: $0.0, poles: $0.1, curveType: $0.2,
                            breakingCapacityKA: $0.3, typicalUse: $0.4)
        }
    }

    // MARK: Standard motor parameters (400V, 50Hz, 4-pole class)

    static func motors() -> [CDCKMotorParam] {
        // (kW, HP, FLA @400V, efficiency, PF)
        let rows: [(Double, Double, Double, Double, Double)] = [
            (0.37, 0.5,  1.1, 0.70, 0.72),
            (0.55, 0.75, 1.5, 0.74, 0.75),
            (0.75, 1.0,  1.9, 0.78, 0.78),
            (1.1,  1.5,  2.7, 0.79, 0.80),
            (1.5,  2.0,  3.5, 0.81, 0.81),
            (2.2,  3.0,  5.0, 0.83, 0.82),
            (3.0,  4.0,  6.6, 0.85, 0.83),
            (4.0,  5.5,  8.5, 0.86, 0.84),
            (5.5,  7.5, 11.5, 0.87, 0.84),
            (7.5, 10.0, 15.5, 0.88, 0.85),
            (11.0,15.0, 22.0, 0.89, 0.85),
            (15.0,20.0, 29.0, 0.90, 0.86),
            (18.5,25.0, 35.0, 0.90, 0.86),
            (22.0,30.0, 41.0, 0.91, 0.87),
            (30.0,40.0, 55.0, 0.92, 0.87),
            (37.0,50.0, 67.0, 0.92, 0.87),
            (45.0,60.0, 80.0, 0.93, 0.88),
            (55.0,75.0, 98.0, 0.93, 0.88)
        ]
        return rows.map {
            CDCKMotorParam(powerKW: $0.0, powerHP: $0.1, voltageV: 400,
                           fullLoadAmpsA: $0.2, efficiency: $0.3,
                           powerFactor: $0.4, poles: 4)
        }
    }

    // MARK: Safety standards

    static func safety() -> [CDCKSafetyStandard] {
        return [
            CDCKSafetyStandard(title: "Low Voltage Working Clearance",
                               content: "Maintain a minimum working clearance of 0.7 m in front of LV (≤1 kV) switchboards and panels. Keep the space clear of stored material to allow safe operation and emergency egress.",
                               category: "Clearance"),
            CDCKSafetyStandard(title: "Medium Voltage Safe Distance",
                               content: "For 1–33 kV equipment keep unqualified personnel at least 3.0 m away from exposed live parts. Only authorised, trained workers may approach within the minimum approach distance defined by local code.",
                               category: "Clearance"),
            CDCKSafetyStandard(title: "Overhead Line Approach",
                               content: "Keep machinery and tools at least 3 m from overhead lines up to 1 kV, and increase the distance for higher voltages. Always treat overhead conductors as live.",
                               category: "Clearance"),
            CDCKSafetyStandard(title: "Lockout / Tagout",
                               content: "Isolate, lock and tag all energy sources before work. Verify zero energy with an approved tester on a known-live source before and after testing the isolated circuit.",
                               category: "Procedure"),
            CDCKSafetyStandard(title: "IP Rating — First Digit (Solids)",
                               content: "IP0X none · IP1X >50 mm · IP2X >12.5 mm (finger) · IP3X >2.5 mm (tool) · IP4X >1 mm (wire) · IP5X dust protected · IP6X dust tight.",
                               category: "IP Rating"),
            CDCKSafetyStandard(title: "IP Rating — Second Digit (Water)",
                               content: "IPX0 none · IPX1 drips · IPX2 drips 15° · IPX3 spray · IPX4 splash · IPX5 jets · IPX6 powerful jets · IPX7 immersion ≤1 m · IPX8 continuous immersion.",
                               category: "IP Rating"),
            CDCKSafetyStandard(title: "Arc Flash PPE",
                               content: "Select arc-rated clothing and face protection matched to the incident energy (cal/cm²) of the task. Never work on energised equipment without the correct PPE category and a permit.",
                               category: "PPE"),
            CDCKSafetyStandard(title: "Conductor Colour Code (IEC)",
                               content: "Line L1 brown · L2 black · L3 grey · Neutral blue · Protective earth green/yellow. Always verify with a tester; legacy installations may differ.",
                               category: "Identification"),
            CDCKSafetyStandard(title: "RCD Protection",
                               content: "A 30 mA RCD provides additional protection against electric shock for socket outlets and circuits supplying portable equipment used outdoors.",
                               category: "Protection"),
            CDCKSafetyStandard(title: "Earthing Continuity Test",
                               content: "Confirm protective conductor continuity (typically ≤1 Ω end-to-end for accessible metalwork) before energising. Record the measured value.",
                               category: "Testing")
        ]
    }
}
