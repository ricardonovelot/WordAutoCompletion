//
//  ContentView.swift
//  WordAutoCompletion
//
//  Created by Ricardo on 28/08/24.
//

import SwiftUI

// maybe you dont need a selectedcontacts, just use the selected property
// NEXT STEP, TO CREATE A TEXT WITH COMPLETIONS AND NOT A LIST ()REGEX POSSIBLY

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    @FocusState var textFieldIsFocused: Bool
    
    var body: some View {
        List {
            
            Image("test")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .listRowInsets(EdgeInsets())
            
            
            Section{
                TextField("", text: $viewModel.searchText, prompt: Text("Test"))
                    .onChange(of: viewModel.searchText) { _ in
                        viewModel.updateSearchResults()
                    }
                    .focused($textFieldIsFocused)
                    .autocorrectionDisabled(true)
                    .onSubmit{
                        textFieldIsFocused = true
                        
                        // move to viewcontroller
                        if let firstResult = viewModel.searchResults.first,
                           let index = viewModel.contacts.firstIndex(where: { $0.id == firstResult.id }) {
                            
                            viewModel.selectedContacts.append(firstResult)
                            viewModel.contacts[index].selected = true
                            viewModel.resetSearchText()
                            
                        }
                    }
            }  header: {
                Text("Input")
            }
            
            Section{
                Text(viewModel.formattedResults)
                
            } header: {
                Text("Results")
            }
            
            
            
            
            Section{
                ForEach(viewModel.searchResults, id: \.self){ contact in
                    Text(contact.name)
                        .foregroundStyle(contact.selected == true ? Color(uiColor: .secondaryLabel) : Color(uiColor: .label))
                }
                .overlay {
                    if viewModel.searchResults.isEmpty {
                        // Custom unavailable view
                        ContentUnavailableView
                            .search(text: viewModel.searchText )
                            .background(Color(UIColor.systemGroupedBackground))
                    }
                }
                
            } header: {
                Text("Contacts")
            }
            
            
        }
        
        
        .navigationTitle("Text Autocomplete")
    }
        
    
}

struct Contact: Hashable, Comparable {
    var id = UUID()
    var name: String
    var selected: Bool
    
    func contains(_ query: String) -> Bool {
        return name.lowercased().contains(query.lowercased())
    }
    
    static func <(lhs: Self, rhs: Self) -> Bool {
        (lhs.selected ? 1:0) < (rhs.selected ? 1:0)
    }
}

extension Contact{
    static var samples: [Contact] {
        return [
            Contact(name: "Rachel Green", selected: false),
            Contact(name: "Phoebe Buffay", selected: false),
            Contact(name: "Chandler Bing", selected: false),
            Contact(name: "Ross Geller", selected: false),
            Contact(name: "Monica Geller", selected: false),
            Contact(name: "Joey Tribbiani", selected: false)
        ]
    }
}

extension ContentView{
    class ContentViewModel: ObservableObject{
        @Published var searchText = ""
        var formattedResults: String {
            let names = selectedContacts.map { $0.name }
            if let string = formatter.string(from: names) {
                return string
            } else {
                return ""
            }
        }
        @Published var isSearchPresented = true
        @Published var contacts: [Contact] = Contact.samples
        @Published var searchResults: [Contact] = []
        @Published var selectedContacts: [Contact] = []
        let formatter = ListFormatter()


//        func createString(){
//            let names = selectedContacts.map { $0.name }
//            if let string = formatter.string(from: names) {
//                formattedResults = string
//            }
//        }
        
        init(){
            fetchSearchResults()
        }
        
        func fetchSearchResults() {
            searchResults = contacts
        }
        
        func updateSearchResults() {
            let query = searchText.lowercased()
            
            if searchText.isEmpty{
                withAnimation(.snappy) {
                    searchResults = contacts.sorted()
                }
            } else {
                withAnimation {
                    searchResults = contacts.filter { contact in
                        contact.contains(query)
                    }
                }
            }
        }
        
        func resetSearchText() {
            searchText = ""
        }
    }
}

#Preview {
    NavigationStack{
        ContentView()
    }
}
