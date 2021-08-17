//
//  MemoryView.swift
//  MemoryView
//
//  Created by Lonnie Gerol on 8/7/21.
//

import SwiftUI
import MapKit

struct MemoryView: View {
    @State var memory: Memory?
    @State var locations:  [UUID:[CLLocationCoordinate2D]] = [:]
    @ObservedObject private var workoutManager = WorkoutManager()

    var body: some View {
        VStack {
            MapView(lineCoordinates: locations)
            VStack(alignment: .leading) {
                Text(memory?.description ?? "Sample Description")
                Text("Total Distance traveled: 69 miles")
                List {
                    if let memory = memory {
                        ForEach(Array(memory.workouts), id: \.uuid) { workout in
                            WorkoutCell(
                                startDate: workout.startDate,
                                endDate: workout.endDate,
                                miles: workout.totalDistance?.doubleValue(for: .mile()) ?? 0,
                                isSelected: false,
                                workoutType: workout.workoutActivityType.supportedWorkout()) {
                                    WorkoutMapPreview(workoutManager: workoutManager, workout: workout)
                                }
                        }

                    } else {
                        Text("Workout 1")
                        Text("Workout 2")
                        Text("Workout 3")
                    }
                }
                .listStyle(.inset)
            }.padding()
        }.onAppear {
            Task {
                self.locations = await WorkoutManager.fetchRouteData(for: Array(memory!.workouts))
            }
        }
    }
}

struct MemoryView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryView()
            .previewInterfaceOrientation(.portrait)
    }
}
