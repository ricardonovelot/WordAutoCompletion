//
//  ContentView.swift
//  WordAutoCompletion
//
//  Created by Ricardo on 28/08/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack{
            Form {
                Section {
                    Text(viewModel.formattedSelectedContacts)
                        .foregroundStyle(.tint)
                } header: {
                    Text("Formatted Results")
                }
                
                Section {
                    TextField("", text: $viewModel.searchQuery, prompt: Text("Enter text"))
                        .onChange(of: viewModel.searchQuery) {
                            viewModel.updateFilteredContacts()
                        }
                        .focused($isTextFieldFocused)
                        .autocorrectionDisabled(true)
                        .onSubmit {
                            isTextFieldFocused = true
                            
                            // Move to viewController
                            if let firstResult = viewModel.filteredContacts.first,
                               let contactIndex = viewModel.allContacts.firstIndex(where: { $0.id == firstResult.id }) {
                                
                                viewModel.allContacts[contactIndex].isSelected = true
                                viewModel.resetSearchQuery()
                            }
                        }
                } header: {
                    Text("Search")
                }
                
                Section {
                    ForEach(viewModel.filteredContacts, id: \.self) { contact in
                        Text(contact.name)
                            .foregroundStyle(contact.isSelected ? Color(uiColor: .secondaryLabel) : Color(uiColor: .label))
                    }
                } header: {
                    Text("Contacts")
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("Autocomplete Search")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button {
                        viewModel.clearSelectedContacts()
                    } label: {
                        Image(systemName: "repeat")
                    }
                }
            }
        }
    }
}

struct Contact: Hashable, Comparable {
    var id = UUID()
    var name: String
    var isSelected: Bool
    
    func contains(_ query: String) -> Bool {
        return name.lowercased().contains(query.lowercased())
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.isSelected ? 1 : 0) < (rhs.isSelected ? 1 : 0)
    }
}

extension Contact {
    static var samples: [Contact] {
        return [
            Contact(name: "Rachel Green", isSelected: false),
            Contact(name: "Phoebe Buffay", isSelected: false),
            Contact(name: "Chandler Bing", isSelected: false),
            Contact(name: "Ross Geller", isSelected: false),
            Contact(name: "Monica Geller", isSelected: false),
            Contact(name: "Joey Tribbiani", isSelected: false)
        ]
    }
}

extension ContentView {
    class ContentViewModel: ObservableObject {
        @Published var searchQuery = ""
        var formattedSelectedContacts: String {
            let selectedContacts = allContacts.filter({ $0.isSelected })
            let names = selectedContacts.map { $0.name }
            return formatter.string(from: names) ?? ""
        }
        @Published var allContacts: [Contact] = Contact.samples
        @Published var filteredContacts: [Contact] = []
        let formatter = ListFormatter()

        init() {
            fetchFilteredContacts()
        }
        
        func fetchFilteredContacts() {
            filteredContacts = allContacts
        }
        
        func updateFilteredContacts() {
            let query = searchQuery.lowercased()
            
            if searchQuery.isEmpty {
                withAnimation(.snappy) {
                    filteredContacts = allContacts.sorted()
                }
            } else {
                withAnimation {
                    filteredContacts = allContacts.filter { $0.contains(query) }
                }
            }
        }
        
        func resetSearchQuery() {
            searchQuery = ""
        }
        
        func clearSelectedContacts() {
            withAnimation {
                for index in allContacts.indices {
                    allContacts[index].isSelected = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
