//
//  HealthManager.swift
//  HealthManager
//
//  Created by Lonnie Gerol on 8/6/21.
//

import HealthKit

class HealthManager {
    static var shared: HealthManager = HealthManager()
    private var healthStore: HKHealthStore!

    private init(){
        self.healthStore = HKHealthStore()
    }

    func executeRequest(query: HKQuery) {
        let healthKitTypesToRead: Set<HKObjectType> = [HKObjectType.workoutType(), HKSeriesType.workoutRoute()]
        // supposed to request authorization every time a HealthKit request is made
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { success, error in
            if let error = error {
                print("an error has occured")
            } else {
                self.healthStore.execute(query)
            }
        }
    }
    func stop(query: HKQuery) {
        self.healthStore.stop(query)
    }
}
