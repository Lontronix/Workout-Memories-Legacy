//
//  Memory+CoreDataClass.swift
//  Memory
//
//  Created by Lonnie Gerol on 8/16/21.
//
//

import Foundation
import CoreData
import HealthKit

public class Memory: NSManagedObject {

    @Published var workouts: Set<HKWorkout>? {
        willSet {
            // ensures this doesn't run when `workouts` is first set
            guard let workouts = workouts else { return }
            guard let newValues = newValue else { return }

            let oldValues = workouts

            let removedWorkouts = oldValues.subtracting(newValues)
            let addedWorkouts = newValues.subtracting(oldValues)

            for hkWorkout in removedWorkouts {
                if let removedWorkout = self.workoutIDs!.filter({$0.workoutID == hkWorkout.uuid}).first {
                    removeFromWorkoutIDs(removedWorkout)
                }
            }

            for hkWorkout in addedWorkouts {
                addToWorkoutIDs(workoutForHKWorkout(hkWorkout: hkWorkout))
            }

        }
    }

    // the HKWorkoutObjects for the associated workouts
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        memoryID = UUID()
        fetchWorkouts()
    }

    func workoutForHKWorkout(hkWorkout: HKWorkout) -> Workout {
        let workout = Workout(context: self.managedObjectContext!)
        workout.workoutID = hkWorkout.uuid
        return workout
    }

    private func fetchWorkouts() {
        guard let workoutIDs = workoutIDs else { return }
        let predicates = workoutIDs.map {
            // this cast should never fail
            HKQuery.predicateForObject(with: $0.workoutID!)
        }

        let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: predicates)

        let query = HKSampleQuery(sampleType: .workoutType(), predicate: compoundPredicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { query, samples, error in
            guard error == nil else {return}
            guard let samples = samples else {return}
            self.workouts =  Set(samples as! [HKWorkout])

        }

        HealthManager.shared.executeRequest(query: query)
    }
}
