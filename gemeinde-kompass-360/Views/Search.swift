//
//  Search.swift
//  gemeinde-kompass-360
//
//  Created by Alex Polan on 06/11/2023.
//

import SwiftUI

struct Search: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
                   Text("Gemeinden Suche \(searchText)")
                       .navigationTitle("Gemeinden Suche")
               }
               .searchable(text: $searchText)
    }
}

#Preview {
    Search()
}
