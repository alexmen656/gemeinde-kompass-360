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
