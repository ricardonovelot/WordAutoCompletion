//
//  ContentView.swift
//  WordAutoCompletion
//
//  Created by Ricardo on 28/08/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    @State var active = false
    
    var body: some View {
        ScrollView {
            Section{
                ForEach(viewModel.selectedNames, id: \.self){ item in
                    Text(item)
                }
            }
            
            
            HStack {
                 HStack {
                     Image(systemName: "magnifyingglass").foregroundColor(.gray)
                     TextField("Search", text: $viewModel.searchText, onEditingChanged: { editing in
                         withAnimation {
                             active = editing
                         }
                     })
                 }
                 .padding(7)
                 .background(Color(white: 0.9))
                 .cornerRadius(10)
                 .padding(.horizontal, active ? 0 : 50)
                 
                 Button("Cancel") {
                     withAnimation {
                         active = false
                     }
                 }
                 .opacity(active ? 1 : 0)
                 .frame(width: active ? nil : 0, height: 0)
             }
            //.searchable(text: $viewModel.searchText, isPresented: $viewModel.isSearchPresented, prompt: "Search")
            .autocorrectionDisabled(true)
            .onSubmit{
                print(viewModel.searchResult.first ?? "")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.searchText = ""
                }
                viewModel.selectedNames.append(viewModel.searchResult.first?.name ?? "")
            }
            .listRowInsets(EdgeInsets())
            
            Section{
                ForEach(viewModel.searchResult, id: \.self){ contact in
                    Text(contact.name)
                }
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
        
        
        .navigationTitle("Test")
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
        @Published var selectedNames: [String] = []
    }
}

#Preview {
    NavigationStack{
        ContentView()
    }
}
