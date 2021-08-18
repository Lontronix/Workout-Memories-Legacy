//
//  Memory+CoreDataProperties.swift
//  Memory
//
//  Created by Lonnie Gerol on 8/17/21.
//
//

import Foundation
import CoreData


extension Memory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Memory> {
        return NSFetchRequest<Memory>(entityName: "Memory")
    }

    @NSManaged public var memoryDescription: String?
    @NSManaged public var memoryID: UUID?
    @NSManaged public var memoryName: String?
    @NSManaged public var workoutIDs: Set<Workout>?

}

// MARK: Generated accessors for workoutIDs
extension Memory {

    @objc(addWorkoutIDsObject:)
    @NSManaged public func addToWorkoutIDs(_ value: Workout)

    @objc(removeWorkoutIDsObject:)
    @NSManaged public func removeFromWorkoutIDs(_ value: Workout)

    @objc(addWorkoutIDs:)
    @NSManaged public func addToWorkoutIDs(_ values: NSSet)

    @objc(removeWorkoutIDs:)
    @NSManaged public func removeFromWorkoutIDs(_ values: NSSet)

}

extension Memory : Identifiable {

}
