//
//  ContentView.swift
//  gemeinde-kompass-360
//
//  Created by Alex Polan on 06/11/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Home().tabItem(){
                Image(systemName: "house")
                Text("Home")
            }//.background(Color.white)
            
            //Comming Soon
          /*  Search().tabItem(){
                Image(systemName: "magnifyingglass")
                Text("Search")
            }*/
            
            Favourites().tabItem(){
                Image(systemName: "heart")
                Text("Favoriten")//Favourites
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
