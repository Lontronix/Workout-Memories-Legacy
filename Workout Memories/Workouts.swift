//
//  Workouts.swift
//  Workouts
//
//  Created by Lonnie Gerol on 8/6/21.
//

import Foundation
import HealthKit
import CoreLocation
import UIKit

enum SupportedWorkout: String, CaseIterable, Identifiable {
    var id: Self { self }

    case outdoorWalk = "Outdoor Walk"
    case outdoorRun = "Outdoor Run"
    case outdoorCycle = "Outdoor Cycle"
}

extension SupportedWorkout {
    func HKWorkoutActivityType() -> HKWorkoutActivityType {
        switch self {
        case .outdoorRun:
            return .running
        case .outdoorWalk:
            return .walking
        case .outdoorCycle:
            return .cycling
        }
    }

    func emoji() -> String {
        switch self {
        case .outdoorRun:
            return "🏃🏻"
        case .outdoorWalk:
            return "🚶🏻"
        case .outdoorCycle:
            return "🚴🏼‍♂️"
        }
    }
}

extension HKWorkoutActivityType {
    func supportedWorkout() -> SupportedWorkout {
        switch self {
        case .cycling:
            return .outdoorCycle
        case .running:
            return .outdoorRun
        case .walking:
            return .outdoorWalk
        default:
            return .outdoorRun
        }
    }
}

@MainActor class WorkoutManager: ObservableObject {
    @Published var workouts: [SupportedWorkout : [HKWorkout]] = [:]
    @Published var snapshots = [HKWorkout: LoadState<UIImage>]()
    // @Published var routeData = [UUID: LoadState<[CLLocationCoordinate2D]>]()

    init() {
        for workoutType in SupportedWorkout.allCases {
            fetchWorkouts(ofType: workoutType, completion: { workoutSamples in
                DispatchQueue.main.async {
                    self.workouts[workoutType] = workoutSamples
                }
            })
        }
    }

    func snapshot(for workout: HKWorkout) -> LoadState<UIImage> {
        if let snapshot = snapshots[workout] {
            return snapshot
        }
        snapshots[workout] = .loading
        Task {
            let routeData = await WorkoutManager.fetchRouteData(for: [workout])
            do {
                let image = try await MapSnapshotter.generateSnapshot(size: CGSize(width: 100, height: 75), coordinates: routeData[workout.uuid] ?? [])
                self.snapshots[workout] = .loaded(image)
                // load the route
                // generate the snapshot image
                // save it in `snapshots`
            } catch {
                self.snapshots[workout] = .failed(error)
            }
        }
        return .loading
    }

    func fetchWorkouts(ofType type: SupportedWorkout, completion: @escaping (([HKWorkout]) -> Void)) {
        let workoutRoutePredicate = HKWorkoutRouteQuery.predicateForWorkouts(with: type.HKWorkoutActivityType())
        let predicate = NSPredicate(format: "metadata.%K != YES", HKMetadataKeyIndoorWorkout)
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [workoutRoutePredicate, predicate])

        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutType(), predicate: compoundPredicate, anchor: nil, limit: HKObjectQueryNoLimit) { query, workouts, deletedWorkouts, anchor, error in

            guard error == nil else {
                fatalError("The inital Query Failed")
            }

            if let workouts = workouts {
                completion(workouts as? [HKWorkout] ?? [])
            }
        }

        HealthManager.shared.executeRequest(query: routeQuery)
    }

    // cancel this in the SwiftUI
    //    func foo() async {
    //        let task = Task {
    //            Self.fetchRouteData(for: [])
    //        }
    //    }

    static func fetchRouteData(for workouts: [HKWorkout]) async -> [UUID:[CLLocationCoordinate2D]] {
        var routes: [UUID:[CLLocationCoordinate2D]] = [:]
        do {
            try await withThrowingTaskGroup(of: (uuid: UUID, coordinates: [CLLocationCoordinate2D]).self) { group in
                for workout in workouts {

                    group.addTask {

                        let runningObjectQuery = HKQuery.predicateForObjects(from: workout)
                        do {
                            let (_ , samples, _ , _) = try await HKWorkoutRouteQuery.anchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit)

                            guard samples.count > 0 else {
                                return (workout.uuid, [])
                            }

                            // second async call
                            let (_ , locations) = try await HKWorkoutRouteQuery.workoutRouteQuery(route: samples[0] as! HKWorkoutRoute)
                            // This block may be called multiple times.
                            return (workout.uuid,locations.map {$0.coordinate})
                        } catch {
                            // Handle any errors here.
                            fatalError("The initial query failed.")
                        }
                    }

                    for try await results in group {
                        routes[results.uuid] = results.coordinates
                    }
                }
            }

        } catch {
            fatalError("Something went wrong")
        }


        return routes
    }
}

// This is necessary because HealthKit doesn't have async calls
extension HKWorkoutRouteQuery {
    static func anchoredObjectQuery(type: HKSampleType, predicate: NSPredicate?, anchor: HKQueryAnchor?, limit: Int) async throws -> (HKAnchoredObjectQuery, [HKSample], [HKDeletedObject], HKQueryAnchor?) {

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKAnchoredObjectQuery(type: type, predicate: predicate, anchor: anchor, limit: limit) { (query, samples, deletedObjects, anchor, error) in
                if let error = error {
                    return continuation.resume(with: .failure(error))
                }

                return continuation.resume(with: .success((query, samples ?? [], deletedObjects ?? [], anchor)))
            }
            Task {
                await withTaskCancellationHandler(handler: {
                    HealthManager.shared.stop(query: query)
                }, operation: {
                    HealthManager.shared.executeRequest(query: query)
                })
            }
        }
    }

    static func workoutRouteQuery(route workoutRoute: HKWorkoutRoute) async throws -> (HKWorkoutRouteQuery, [CLLocation]) {
        return try await withCheckedThrowingContinuation { continuation in
            var allLocations = [CLLocation]()
            let query = HKWorkoutRouteQuery(route: workoutRoute) { (query, locationsOrNil, done, errorOrNil) in

                // This block may be called multiple times.
                if let error = errorOrNil {
                    return continuation.resume(with: .failure(error))
                }

                guard done else {
                    assert(locationsOrNil != nil)
                    return allLocations.append(contentsOf: locationsOrNil!)
                }

                return continuation.resume(with: .success((query, allLocations)))
            }

            Task {
                await withTaskCancellationHandler(handler: {
                    HealthManager.shared.stop(query: query)
                }, operation: {
                    HealthManager.shared.executeRequest(query: query)
                })
            }
        }
    }
}
