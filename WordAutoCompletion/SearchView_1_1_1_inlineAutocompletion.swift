//
//  ContentView.swift
//  WordAutoCompletion
//
//  Created by Ricardo on 28/08/24.
//

import SwiftUI

struct SearchView_1_1_1_inlineAutocompletion: View {
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
                    HStack {
                        ZStack(alignment: .leading) {
                            // Show query and highlighted completion
                            Text(viewModel.searchQuery) +
                            Text(viewModel.completionText)
                                .foregroundColor(.gray) // Highlight completion
                            
                            TextField("", text: $viewModel.searchQuery, prompt: Text("Start Typing Here"))
                                .onChange(of: viewModel.searchQuery) {
                                    viewModel.filterContactsBySearchQuery()
                                }
                                .focused($textFieldIsFocused)
                                .autocorrectionDisabled(true)
                                .onSubmit {
                                    viewModel.selectFirstSearchResult()
                                }
                                .keyboardType(.default)
                                .onKeyPress { keyPress in
                                    if keyPress.characters == " " { // Detect spacebar
                                        viewModel.selectFirstSearchResult()
                                        return .handled
                                    }
                                    return .ignored
                                }
                        }
                    }
                } header: {
                    Text("Search")
                }
                
                Section {
                    ForEach(viewModel.filteredUnselectedContacts, id: \.id) { contact in
                        Text(contact.name)
                    }
                } header: {
                    Text("Contacts")
                }
            }
            .navigationTitle("Search Suggestions TESTT")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button(action: viewModel.resetSearchQuery) {
                        Label("Reset", systemImage: "xmark.circle")
                    }
                }
            }
        }
    }
}


struct Contact_1_1_1: Hashable {
    var id = UUID()
    var name: String
    
    func contains(_ query: String) -> Bool {
        return name.lowercased().contains(query.lowercased())
    }
}

extension Contact_1_1_1 {
    static var samples: [Contact_1_1_1] {
        return [
            Contact_1_1_1(name: "Rachel Green"),
            Contact_1_1_1(name: "Phoebe Buffay"),
            Contact_1_1_1(name: "Chandler Bing"),
            Contact_1_1_1(name: "Ross Geller"),
            Contact_1_1_1(name: "Monica Geller"),
            Contact_1_1_1(name: "Joey Tribbiani")
        ]
    }
}

extension SearchView_1_1_1_inlineAutocompletion {
    class ContactViewModel: ObservableObject {
        @Published var searchQuery = ""
        @Published var formattedContactList = ""
        @Published var completionText = "" // Stores the completion
        @Published var unselectedContacts: [Contact_1_1_1] = Contact_1_1_1.samples
        @Published var selectedContacts: [Contact_1_1_1] = []
        @Published var filteredUnselectedContacts: [Contact_1_1_1] = []
        let listFormatter = ListFormatter()

        func updateFormattedResults() {
            let names = selectedContacts.map { $0.name }
            if let string = listFormatter.string(from: names) {
                withAnimation {
                    formattedContactList = string
                }
            }
        }

        func filterContactsBySearchQuery() {
            let query = searchQuery.lowercased()
            
            if query.isEmpty {
                filteredUnselectedContacts = unselectedContacts
                completionText = ""
                return
            }

            // Clear completion if user is deleting characters
            if completionText.isEmpty || !query.hasSuffix(completionText) {
                filteredUnselectedContacts = unselectedContacts.filter { $0.contains(query) }
                if let firstResult = filteredUnselectedContacts.first {
                    let fullName = firstResult.name.lowercased()
                    if fullName.hasPrefix(query) {
                        let completionIndex = fullName.index(fullName.startIndex, offsetBy: query.count)
                        completionText = String(fullName[completionIndex...])
                    }
                } else {
                    completionText = ""
                }
            }
        }


        func resetSearchQuery() {
            searchQuery = ""
            completionText = ""
        }

        func selectFirstSearchResult() {
            if let firstResult = filteredUnselectedContacts.first {
                selectedContacts.append(firstResult)
                updateFormattedResults()
                resetSearchQuery()
            }
        }
    }

}

#Preview {
    SearchView_1_1_1_inlineAutocompletion()
}
