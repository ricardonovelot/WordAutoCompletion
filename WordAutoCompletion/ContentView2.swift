//
//  ContentView.swift
//  WordAutoCompletion
//
//  Created by Ricardo on 28/08/24.
//

import SwiftUI

struct ContactSearchView: View {
    @ObservedObject var viewModel = ContactViewModel()
    @FocusState var textFieldIsFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(viewModel.formattedContactList)
                        .foregroundStyle(.tint)
                } header: {
                    Text("Formatted Results")
                }
                
                Section {
                    TextField("", text: $viewModel.searchQuery, prompt: Text("Search"))
                        .onChange(of: viewModel.searchQuery) {
                            viewModel.filterContactsBySearchQuery()
                        }
                        .focused($textFieldIsFocused)
                        .autocorrectionDisabled(true)
                        .onSubmit {
                            textFieldIsFocused = true
                            
                            if let firstResult = viewModel.filteredUnselectedContacts.first,
                               let index = viewModel.unselectedContacts.firstIndex(where: { $0.id == firstResult.id }) {
                                viewModel.unselectedContacts.remove(at: index)
                                viewModel.selectedContacts.append(firstResult)
                                viewModel.updateFormattedResults()
                                viewModel.resetSearchQuery()
                            }
                        }
                } header: {
                    Text("Input")
                }
                
                Section {
                    ForEach(viewModel.filteredUnselectedContacts, id: \.id) { contact in
                        Text(contact.name)
                    }
                    
                    ForEach(viewModel.filteredSelectedContacts, id: \.id) { contact in
                        Text(contact.name)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
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
                        viewModel.resetAllContacts()
                    } label: {
                        Image(systemName: "repeat")
                    }
                }
            }
        }
    }
}

struct Contact2: Hashable {
    var id = UUID()
    var name: String
    
    func contains(_ query: String) -> Bool {
        return name.lowercased().contains(query.lowercased())
    }
}

extension Contact2 {
    static var samples: [Contact2] {
        return [
            Contact2(name: "Rachel Green"),
            Contact2(name: "Phoebe Buffay"),
            Contact2(name: "Chandler Bing"),
            Contact2(name: "Ross Geller"),
            Contact2(name: "Monica Geller"),
            Contact2(name: "Joey Tribbiani")
        ]
    }
}

extension ContactSearchView {
    class ContactViewModel: ObservableObject {
        @Published var searchQuery = ""
        @Published var formattedContactList = ""
        @Published var isSearchPresented = true
        @Published var unselectedContacts: [Contact2] = Contact2.samples
        @Published var selectedContacts: [Contact2] = []
        @Published var filteredUnselectedContacts: [Contact2] = []
        @Published var filteredSelectedContacts: [Contact2] = []
        let listFormatter = ListFormatter()

        func updateFormattedResults() {
            let names = selectedContacts.map { $0.name }
            if let string = listFormatter.string(from: names) {
                formattedContactList = string
            }
        }
        
        init() {
            initializeSearchResults()
        }
        
        func initializeSearchResults() {
            filteredUnselectedContacts = unselectedContacts
            filteredSelectedContacts = selectedContacts
        }
        
        func filterContactsBySearchQuery() {
            let query = searchQuery.lowercased()
            
            if searchQuery.isEmpty {
                withAnimation(.snappy) {
                    filteredUnselectedContacts = unselectedContacts
                    filteredSelectedContacts = selectedContacts
                }
            } else {
                withAnimation {
                    filteredUnselectedContacts = unselectedContacts.filter { $0.contains(query) }
                    filteredSelectedContacts = selectedContacts.filter { $0.contains(query) }
                }
            }
        }
        
        func resetSearchQuery() {
            searchQuery = ""
        }
        
        func resetAllContacts() {
            withAnimation {
                unselectedContacts = Contact2.samples
                selectedContacts.removeAll()
                filterContactsBySearchQuery()
                updateFormattedResults()
            }
        }
    }
}

#Preview {
    ContactSearchView()
}
