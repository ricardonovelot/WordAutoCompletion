//
//  ContentView.swift
//  WordAutoCompletion
//
//  Created by Ricardo on 28/08/24.
//

import SwiftUI

struct SearchView_1_1_2_MultipleViews: View {
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
                        .onChange(of: viewModel.searchQuery) {
                            viewModel.filterContactsBySearchQuery()
                        }
                        .focused($textFieldIsFocused)
                        .autocorrectionDisabled(true)
                        .onSubmit {
                            textFieldIsFocused = true
                            viewModel.selectFirstSearchResult()
                        }
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

struct Contact3: Hashable {
    var id = UUID()
    var name: String
    
    func contains(_ query: String) -> Bool {
        return name.lowercased().contains(query.lowercased())
    }
}

extension Contact3 {
    static var samples: [Contact3] {
        return [
            Contact3(name: "Rachel Green"),
            Contact3(name: "Phoebe Buffay"),
            Contact3(name: "Chandler Bing"),
            Contact3(name: "Ross Geller"),
            Contact3(name: "Monica Geller"),
            Contact3(name: "Joey Tribbiani")
        ]
    }
}

extension SearchView_1_1_2_MultipleViews {
    class ContactViewModel: ObservableObject {
        @Published var searchQuery = ""
        @Published var formattedContactList = ""
        @Published var isSearchPresented = true
        @Published var showLearnMoreSheet: Bool = false
        @Published var unselectedContacts: [Contact3] = Contact3.samples
        @Published var selectedContacts: [Contact3] = []
        @Published var filteredUnselectedContacts: [Contact3] = []
        @Published var filteredSelectedContacts: [Contact3] = []
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
                unselectedContacts = Contact3.samples
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
        }
        
    }
}

#Preview {
    SearchView_1_1_2_MultipleViews()
}
