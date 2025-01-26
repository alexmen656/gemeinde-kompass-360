//
//  Home.swift
//  gemeinde-kompass-360
//
//  Created by Alex Polan on 06/11/2023.
//

import SwiftUI
import SwiftData

class PostViewModel: ObservableObject {
    @Published var postData = [Item]()
    
    func fetchData() async {
        var downloadedPosts: [Item] = []

        do {
            downloadedPosts = try await WebService().downloadData(fromURL: "https://alex.polan.sk/api/gemeinde-kompass-360/gemeinden.php")
        } catch {
            // Handle the error if necessary
            print("Error downloading data: \(error)")
            return
        }

        // Handle downloadedPosts as needed
        postData = downloadedPosts
        //print(postData)
    }

}


struct Home: View {
   // @Environment(\.modelContext) private var modelContext
    //@Query private var items: [Item]
    @StateObject var vm = PostViewModel()
    
    
    var body: some View {
        /*  Button(action: addItem) {
         Label("Add Item", systemImage: "plus")
         }*/
        NavigationView {
            ScrollView {
                //   NavigationLink(destination: Gemeinde()) {
                
                /*       Label("Start", systemImage: "play")
                 .padding([.bottom, .top] , 25)
                 .foregroundColor(Color.black)
                 .fontWeight(.heavy)
                 .frame(width: 300)
                 }*/
             //   Text("Entdecke Gemeinden in Österreich")
                Text("Entdecke Österreich").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: 18))//Discover Austria
                ForEach(vm.postData) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        AsyncImage(url: URL(string: "https://alex.polan.sk/api/gemeinde-kompass-360/images/"+item.bild)) { phase in
                                   switch phase {
                                   case .empty:
                                       // Placeholder view while the image is loading
                                       ProgressView()
                                   case .success(let image):
                                       // Resizable image with a specific frame
                                       ZStack {
                                       image
                                           .resizable()
                                           .scaledToFit()
                                           Text("TEST2233").background(Color.black)
                                       }
                                   case .failure:
                                       // Placeholder view when there's an error loading the image
                                  //     Text("Bild konnte nicht geladen werden")
                                       Image("CardImage") .resizable()
                                           .scaledToFit()

                                   @unknown default:
                                       // Placeholder view for future updates
                                      // Text("Bild konnte nicht geladen werden")
                                       Image("CardImage") .resizable()
                                           .scaledToFit()

                                   }
                               }
                        VStack(alignment: .leading) {
                            NavigationLink(destination: Gemeinde(gemeinde: item)) {
                                
                                Text(item.name).fontWeight(.semibold).font(.title2).foregroundColor(.black)//.padding(.bottom, 16)//.border(Color.blue)
                            }
                            Text(item.beschreibung).padding(.bottom, 18)

                           /* HStack {
                                Image(systemName: "shippingbox")
                                Text(item.plz)
                            }.padding(.bottom, 18)*/
                        }.padding(12)//6
                        //  Text(item.title)
                        // Text(item.title)
                        //Text(item.title)
                        
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
        /*
         ForEach(vm.postData) { item in
         
                 VStack {
                     Image("CardImage").resizable().scaledToFit()
                     //Text(item.title)
                     
                 }.border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
          //   }.padding(10).border(Color.orange)
             
         }.border(Color.brown).onAppear {
             if vm.postData.isEmpty {
                 Task {
                     await vm.fetchData()
                 }
             
             }
         }
         */
        }
        
    
    
    private func addItem() {
        /*withAnimation {
         
         let newItem = Item(id: 0, name: "Deutsch Jahrndorf")
         let newItem2 = Item(id: 1, name: "Deutsch Jahrndorf")
         modelContext.insert(newItem)
         modelContext.insert(newItem2)
         }
         }*/
        print(1);
    }
}
#Preview {
    Home()//.modelContainer(for: Item.self, inMemory: true)

}
