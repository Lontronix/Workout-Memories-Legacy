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
    @State private var origin = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.333705,
                                                                          longitude: -122.0105905),
                                           span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))

    var body: some View {
        VStack {
            Map(coordinateRegion: $origin)
            VStack(alignment: .leading) {
                Text(memory?.description ?? "Sample Description")
                Text("Total Distance traveled: 69 miles")
                List {
                    if let memory = memory {
                        ForEach(Array(memory.workouts), id: \.uuid) { workout in
                            Text("I am a workout")
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
                await WorkoutManager.fetchRouteData(for: Array(memory!.workouts))
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
