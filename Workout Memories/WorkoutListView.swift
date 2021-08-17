//
//  WorkoutListView.swift
//  WorkoutListView
//
//  Created by Lonnie Gerol on 8/6/21.
//

import SwiftUI
import HealthKit

struct WorkoutCell: View {
    var startDate: Date
    var endDate: Date
    var miles: Double
    var isSelected: Bool
    var workoutType: SupportedWorkout

    var body: some View {
        HStack {
            Text(workoutType.emoji())
            VStack(alignment: .leading) {
                Text(startDate, format: .dateTime)
                Text(startDate..<endDate, format: .components(style: .abbreviated, fields: [.hour, .minute, .second]))
                    .font(.caption)

                Text("\(miles.formatted(.number.precision(.significantDigits(2)))) miles")
                    .font(.caption)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
        }
    }
}

struct WorkoutListView: View {
    @State private var selection: SupportedWorkout = .outdoorWalk
    @State private var selectedWorkouts = Set<HKWorkout>()
    @Binding var commitedWorkouts: Set<HKWorkout>
    @Binding var isPresenting: Bool
    @Environment(\.dismiss) var dismiss
    @ObservedObject var workoutManager: WorkoutManager

    func cell(for workout: HKWorkout) -> some View {
        WorkoutCell(
            startDate: workout.startDate,
            endDate: workout.startDate + workout.duration,
            miles: workout.totalDistance?.doubleValue(for: .mile()) ?? 0,
            isSelected: selectedWorkouts.contains(workout),
            workoutType:  workout.workoutActivityType.supportedWorkout()
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("Test", selection: $selection){
                    ForEach(SupportedWorkout.allCases) { workout in
                        Text(workout.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                if let item = workoutManager.workouts[selection] {
                    List(item, id: \.self) { workout in
                        Button {
                            if selectedWorkouts.contains(workout) {
                                selectedWorkouts.remove(workout)
                            } else {
                                selectedWorkouts.insert(workout)
                            }
                        } label: {
                            cell(for: workout)
                        }
                    }
                    .listStyle(.plain)
                } else {
                    Text("No Workouts")
                        .frame(maxHeight: .infinity)
                }
            }
            .padding()
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {

                    Button {
                        commitedWorkouts = selectedWorkouts
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
        .onAppear {
            selectedWorkouts = commitedWorkouts
        }
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WorkoutCell(startDate: .now, endDate: .now + 1000, miles: 2, isSelected: true, workoutType: .outdoorRun)
            WorkoutCell(startDate: .now, endDate: .now + 100, miles: 0.6, isSelected: false, workoutType: .outdoorRun)
            WorkoutCell(startDate: .now, endDate: .now + 100, miles: 0.6, isSelected: false, workoutType: .outdoorRun)
                .preferredColorScheme(.dark)
        }
        .padding()
    }
}
