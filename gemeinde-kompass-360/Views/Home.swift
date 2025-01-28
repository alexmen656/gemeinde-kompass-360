import SwiftUI
import SwiftData

class PostViewModel: ObservableObject {
    @Published var postData = [Item]()
    @Published var filteredData = [Item]()
    
    func fetchData() async {
        var downloadedPosts: [Item] = []

        do {
            downloadedPosts = try await WebService().downloadData(fromURL: "https://www.gk360.at/api/municipalities/ios.php?action=all&limit=400")
        } catch {
            // Handle the error if necessary
            print("Error downloading data: \(error)")
            return
        }

        // Handle downloadedPosts as needed
        postData = downloadedPosts
        filteredData = downloadedPosts
    }
    
    func filterData(byFederalState federalState: String, andDistrict district: String) {
        filteredData = postData.filter { item in
            (federalState.isEmpty || item.federalState == federalState) && (district.isEmpty || item.district == district)
        }
    }
}

struct Home: View {
    @StateObject var vm = PostViewModel()
    @State private var selectedFederalState: String = ""
    @State private var selectedDistrict: String = ""
    @State private var showFilterView = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    HStack {
                        Text("Explore Austria")
                            .fontWeight(.bold)
                            .font(.system(size: 28))
                        
                        Spacer()
                        
                        Button(action: {
                            showFilterView.toggle()
                        }) {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .font(.title2)
                        }
                        .sheet(isPresented: $showFilterView) {
                            FilterView(postData: vm.postData, selectedFederalState: $selectedFederalState, selectedDistrict: $selectedDistrict, applyFilter: {
                                vm.filterData(byFederalState: selectedFederalState, andDistrict: selectedDistrict)
                                showFilterView = false
                            })
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 18)
                    .padding(.bottom, 12)
                    
                    
                    HStack {
                        if !selectedFederalState.isEmpty {
                            TagView(text: selectedFederalState) {
                                selectedFederalState = ""
                                vm.filterData(byFederalState: selectedFederalState, andDistrict: selectedDistrict)
                            }
                        }
                        if !selectedDistrict.isEmpty {
                            TagView(text: selectedDistrict) {
                                selectedDistrict = ""
                                vm.filterData(byFederalState: selectedFederalState, andDistrict: selectedDistrict)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(vm.filteredData) { item in
                        VStack(alignment: .leading, spacing: 10) {
                            AsyncImage(url: URL(string: item.image)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    ZStack {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    }
                                case .failure:
                                    Image("CardImage")
                                        .resizable()
                                        .scaledToFit()
                                @unknown default:
                                    Image("CardImage")
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                               VStack(alignment: .leading) {
                            NavigationLink(destination: Gemeinde(gemeinde: item)) {
                                
                                Text(item.name).fontWeight(.semibold).font(.title2).foregroundColor(.black)
                            }
                                   Text("\(item.name) is a \(item.name == "Bregenz" ? "city" : "village") in the \(item.district) district, \(item.federalState). It has an area of \(String(format: "%.2f", item.area)) km² and a population of \(item.population).")
    .padding(.bottom, 18)                   }.padding(12)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20.0))
                        .shadow(radius: 8)
                        .padding(15)
                    }
                }
                .onAppear {
                    if vm.postData.isEmpty {
                        Task {
                            await vm.fetchData()
                        }
                    }
                }
            }
        }
    }
}

struct FilterView: View {
    var postData: [Item]
    @Binding var selectedFederalState: String
    @Binding var selectedDistrict: String
    var applyFilter: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Federal State", selection: $selectedFederalState) {
                    Text("Select Federal State").tag("")
                    ForEach(postData.map { $0.federalState }.unique(), id: \.self) { federalState in
                        Text(federalState).tag(federalState)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Picker("Select District", selection: $selectedDistrict) {
                    Text("Select District").tag("")
                    ForEach(postData.map { $0.district }.unique(), id: \.self) { district in
                        Text(district).tag(district)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle("Filter")
            .navigationBarItems(trailing: Button("Done") {
                applyFilter()
            })
        }
    }
}

struct TagView: View {
    var text: String
    var onRemove: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}
