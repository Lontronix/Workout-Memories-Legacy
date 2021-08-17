//
//  ContentView.swift
//  Workout Memories
//
//  Created by Lonnie Gerol on 8/6/21.
//

import SwiftUI

struct MemoriesListView: View {
    @State var presentingModal = false
    @State var memories = Set<Memory>()

    func cell(for memory: Memory) -> some View {
        NavigationLink(destination: {
            MemoryView(memory: memory)
                .navigationTitle(memory.name)
                .navigationBarTitleDisplayMode(.inline)
        }) {
            VStack(alignment: .leading ){
                Text(memory.name)
                Text(memory.description)
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    func memoryListView() -> some View {
        if memories.isEmpty {
            VStack(alignment: .center) {
                Text("No Memories")
                Text("Once you add a memory you will see it here")
                    .font(.subheadline)
            }
        } else {
            List {
                ForEach(Array(memories)) { memory in
                    cell(for: memory)
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            memoryListView()
                .navigationTitle("Memories")

                .toolbar {
                    Button(action: {
                        presentingModal.toggle()
                        print("Button Pressed")
                    }) {
                        Image(systemName: "plus")
                    }
                }
        }.popover(isPresented: $presentingModal) {
            MemoryCreationView(memories: $memories)
        }
        #if DEBUG
        .onAppear {
            Memory.createSampleMemory { memory in
                self.memories.insert(memory)
            }
        }
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesListView()
    }
}
