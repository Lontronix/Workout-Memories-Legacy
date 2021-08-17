//
//  WorkoutListView.swift
//  WorkoutListView
//
//  Created by Lonnie Gerol on 8/6/21.
//

import SwiftUI
import HealthKit

struct MemoryCreationView : View {

    // MARK: Private State
    @State private var memoryName = ""
    @State private var memoryDescription = ""
    @State private var addWorkoutsPresented = false
    @StateObject private var workoutManager = WorkoutManager()
    @Environment(\.dismiss) private var dismiss

    // MARK: Public State
    @State private var selectedWorkouts = Set<HKWorkout>()
    var memories: Binding<Set<Memory>>?

    private func saveButtonPressed() {
        if let memories = memories {
            memories.wrappedValue.insert(Memory(
                name: memoryName,
                description: memoryDescription,
                workouts: selectedWorkouts
            )
)
        }
        dismiss()
    }

    func cell(for workout: HKWorkout) -> some View {
        WorkoutCell(
            startDate: workout.startDate,
            endDate: workout.startDate + workout.duration,
            miles: workout.totalDistance?.doubleValue(for: .mile()) ?? 0,
            isSelected: false,
            workoutType:  workout.workoutActivityType.supportedWorkout()
        )
            .swipeActions(content: {
                Button(action: {

                }) {
                    Text("Delete")
                        .foregroundColor(.red)
                }
            })
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Memory name")) {
                    TextField("Memory Name", text: $memoryName)
                }
                Section(header: Text("Memory Descrription")) {
                    TextEditor(text: $memoryDescription)
                }
                Section(header: Text("workouts")) {
                    List {
                        ForEach(Array(selectedWorkouts), id: \.self) { workout in
                            cell(for: workout)
                        }
                        Button(action: {
                            addWorkoutsPresented.toggle()

                        }) {
                            HStack(alignment: .center) {
                                Image(systemName: "plus")
                                Text("Add Workout(s)")
                            }
                        }
                    }
                }
                Section {
                    Button(action: {
                        saveButtonPressed()
                    }) {
                        Text("Save")
                    }
                }
            }.popover(isPresented: $addWorkoutsPresented) {
                WorkoutListView(commitedWorkouts: $selectedWorkouts, isPresenting: $addWorkoutsPresented, workoutManager: workoutManager)
            }
            .navigationTitle("Create Memory")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {

                    Button(action: {
                        saveButtonPressed()
                    }) {
                        Text("Save")
                    }
                }
            }
        }}
}

struct MemoryCreationView_Preview: PreviewProvider {
    static var previews: some View {
        MemoryCreationView()
    }
}
