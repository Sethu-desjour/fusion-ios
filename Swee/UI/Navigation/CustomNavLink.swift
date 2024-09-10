//
//  CustomNavLink.swift
//  Swee
//
//  Created by Serghei on 09.09.2024.
//

import SwiftUI

struct CustomNavLink<Label: View, Destination: View>: View {
    
    let destination: Destination
    let label: Label
    
    init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }
    
    var body: some View {
        NavigationLink(destination: CustomNavBarContainerView(content: {
            destination
        })
            .navigationBarHidden(true)
        ) {
            label
        }
    }
}

//#Preview {
//    CustomNavLink()
//}
