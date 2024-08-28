//
//  ContentView.swift
//  WordAutoCompletion
//
//  Created by Ricardo on 28/08/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    
    
    var body: some View {
        NavigationStack {
            Section{
                List(viewModel.searchResult, id: \.self){ contact in
                    Text(contact.name)
                }
                .navigationTitle("Word Auto Completion")
                .searchable(text: $viewModel.searchText, isPresented: $viewModel.isSearchPresented, prompt: "Search")
                .overlay {
                    if viewModel.searchResult.isEmpty {
                        // Custom unavailable view
                        ContentUnavailableView
                            .search(text: viewModel.searchText )
                            .background(Color(UIColor.systemGroupedBackground))
                        
                    }
                }
            }
        }
    }
}

struct Contact: Hashable {
    var name: String
    
    func contains(_ query: String) -> Bool {
        return name.lowercased().contains(query.lowercased())
    }
}

extension Contact{
    static var samples: [Contact] {
        return [
            Contact(name: "Rachel Green"),
            Contact(name: "Phoebe Buffay"),
            Contact(name: "Chandler Bing"),
            Contact(name: "Ross Geller"),
            Contact(name: "Monica Geller"),
            Contact(name: "Joey Tribbiani")
        ]
    }
}

extension ContentView{
    class ContentViewModel: ObservableObject{
        @Published var searchText = ""
        @Published var isSearchPresented = true
        @Published var contacts: [Contact] = Contact.samples
        var searchResult: [Contact] {
            if searchText.isEmpty {
                return contacts
            } else {
                return contacts.filter {
                    $0.contains(searchText)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
