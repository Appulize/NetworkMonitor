//
//  NetworkStatusDescriptionView.swift
//  
//
//  Created by Maciej Swic on 2022-06-04.
//

import SwiftUI

public struct NetworkStatusDescriptionView: View {
    @ObservedObject var networkMonitor = NetworkMonitor
        .shared
    
    var body: some View {
        Text(networkMonitor.description)
    }
}

@available(iOS 14.0, *)
struct NetworkStatusDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                Section {
                    Text("Hello, World!")
                } footer: {
                    NetworkStatusDescriptionView()
                }
            }
            .navigationTitle("NetworkMonitor")
        }
    }
}
