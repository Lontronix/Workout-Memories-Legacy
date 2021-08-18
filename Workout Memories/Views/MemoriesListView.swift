//
//  ContentView.swift
//  Workout Memories
//
//  Created by Lonnie Gerol on 8/6/21.
//

import SwiftUI

struct MemoriesListView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @FetchRequest(
        entity: Memory.entity(),
        sortDescriptors: [],
        predicate: nil,
        animation: nil
    ) private var memories: FetchedResults<Memory>
    @State private var presentingModal = false

    func cell(for memory: Memory) -> some View {
        NavigationLink(destination: {
            MemoryView(memory: memory)
                .navigationTitle(memory.memoryName ?? "")
                .navigationBarTitleDisplayMode(.inline)
        }) {
            VStack(alignment: .leading ){
                Text(memory.memoryName ?? "No Name")
                Text(memory.memoryDescription ?? "No Description")
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
                        .swipeActions {
                            Button {
                                PersistenceController.delete(item: memory, withContext: managedObjectContext)
                            } label: {
                                Image(systemName: "trash")
                                    .symbolVariant(.fill)
                            }.tint(.red)
                        }
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
                    }) {
                        Image(systemName: "plus")
                    }
                }
        }.popover(isPresented: $presentingModal) {
            MemoryCreationView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesListView()
    }
}
