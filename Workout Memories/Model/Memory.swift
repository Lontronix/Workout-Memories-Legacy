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

    #if DEBUG
    static func createSampleMemory(completionHandler: @escaping ((Memory) -> Void)) {
        // BA7E0C77-A79A-486C-96B8-37BBD99AB9D4 - 7/29 outdoor walk at RIT
        // C5F9755D-BB2F-444A-AC65-EF1BBF6065D8 - 7/29 outdor run @ RIT?

        let predicateOne = HKQuery.predicateForObject(with: UUID(uuidString: "BA7E0C77-A79A-486C-96B8-37BBD99AB9D4")!)
        let predicateTwo = HKQuery.predicateForObject(with: UUID(uuidString: "C5F9755D-BB2F-444A-AC65-EF1BBF6065D8")!)
        let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: [predicateOne, predicateTwo])

        let query = HKSampleQuery(sampleType: .workoutType(), predicate: compoundPredicate, limit: 2, sortDescriptors: nil) { query, samples, error in
            guard error == nil else {
                print("An error occured while fetching sample data \(error!)")
                return
            }

            let memory = Memory(name: "Sample Memory",
                                description: "This is a sample description of a memory",
                                workouts: Set(samples! as! [HKWorkout]))
            completionHandler(memory)
        }

        HealthManager.shared.executeRequest(query: query)
    }
    #endif
}
