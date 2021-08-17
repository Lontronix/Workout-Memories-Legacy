//
//  Memory.swift
//  Memory
//
//  Created by Lonnie Gerol on 8/7/21.
//

import HealthKit
import MapKit

struct Memory: Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var workouts: Set<HKWorkout>


//    func generatePolyline() -> MKPolyline {
//        let firstWorkout = self.workouts.first
//    }
}
