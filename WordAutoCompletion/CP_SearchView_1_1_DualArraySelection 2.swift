//
//  ContentView.swift
//  WordAutoCompletion
//
//  Created by Ricardo on 28/08/24.
//

import SwiftUI

struct SearchView_DA_Manual_Selection: View {
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
                    TextField("", text: $viewModel.searchQuery, prompt: Text("Start Typing Here"))
                        .onChange(of: viewModel.searchQuery) { oldValue, newValue in
                            if newValue.last == " " { //.onKeyPress(.space) { // Space not working on iOS
                                viewModel.searchQuery = newValue.trimmingCharacters(in: .whitespaces) // Detect space key but remove trailing space for filtering purposes
                                viewModel.selectFirstSearchResult()
                                textFieldIsFocused = true
                            } else {
                                viewModel.filterContactsBySearchQuery()
                            }
                        }
                        .focused($textFieldIsFocused)
                        .autocorrectionDisabled(true)
                        
                } header: {
                    Text("Search")
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
            .navigationTitle("Search Suggestions")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button(action: viewModel.resetAllContacts){
                        Label("Reset", systemImage: "repeat")
                    }
                }
            }
        }
    }
}

struct Contact_1_1_4: Hashable {
    var id = UUID()
    var name: String
    
    func contains(_ query: String) -> Bool {
        return name.lowercased().contains(query.lowercased())
    }
}

extension Contact_1_1_4 {
    static var samples: [Contact_1_1_4] {
        return [
            Contact_1_1_4(name: "Rachel Green"),
            Contact_1_1_4(name: "Phoebe Buffay"),
            Contact_1_1_4(name: "Chandler Bing"),
            Contact_1_1_4(name: "Ross Geller"),
            Contact_1_1_4(name: "Monica Geller"),
            Contact_1_1_4(name: "Joey Tribbiani")
        ]
    }
}

extension SearchView_DA_Manual_Selection {
    class ContactViewModel: ObservableObject {
        @Published var searchQuery = ""
        @Published var formattedContactList = ""
        @Published var isSearchPresented = true
        @Published var showLearnMoreSheet: Bool = false
        @Published var unselectedContacts: [Contact_1_1_4] = Contact_1_1_4.samples
        @Published var selectedContacts: [Contact_1_1_4] = []
        @Published var filteredUnselectedContacts: [Contact_1_1_4] = []
        @Published var filteredSelectedContacts: [Contact_1_1_4] = []
        let listFormatter = ListFormatter()

        func updateFormattedResults() {
            let names = selectedContacts.map { $0.name }
            if let string = listFormatter.string(from: names) {
                withAnimation {
                    formattedContactList = string
                }
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
                unselectedContacts = Contact_1_1_4.samples
                selectedContacts.removeAll()
                filterContactsBySearchQuery()
                updateFormattedResults()
            }
        }
        
        func selectFirstSearchResult(){
            if let firstResult = filteredUnselectedContacts.first,
               let index = unselectedContacts.firstIndex(where: { $0.id == firstResult.id }) {
                unselectedContacts.remove(at: index)
                selectedContacts.append(firstResult)
                updateFormattedResults()
            }
            resetSearchQuery()
        }
        
    }
}

#Preview {
    SearchView_DA_Manual_Selection()
}


