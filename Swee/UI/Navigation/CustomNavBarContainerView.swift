//
//  CustomNavBarContainerView.swift
//  Swee
//
//  Created by Serghei on 09.09.2024.
//

import SwiftUI

struct CustomNavBarContainerView<Content: View>: View {
    let content: Content
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showBackButton: Bool = true
    @State private var leadingItem: EquatableViewContainer = EquatableViewContainer(view: AnyView(Text("")))
    @State private var trailingItem: EquatableViewContainer = EquatableViewContainer(view: AnyView(Text("")))
    @State private var title: String = ""
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavBarView(showBackButton: showBackButton, leadingItem: leadingItem, trailingItem: trailingItem, title: title)
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onPreferenceChange(CustomNavBarTitlePreferenceKey.self, perform: { value in
            self.title = value
        })
        .onPreferenceChange(CustomNavBarBackButtonHiddenPreferenceKey.self, perform: { value in
            self.showBackButton = !value
        })
        .onPreferenceChange(CustomNavLeadingItemPreferenceKey.self, perform: { value in
            self.leadingItem = value
        })
        .onPreferenceChange(CustomNavTrailingItemPreferenceKey.self, perform: { value in
            self.trailingItem = value
        })
    }
}

#Preview {
    CustomNavBarContainerView {
        ZStack {
            Color.green
                .ignoresSafeArea()
            Text("Hello world!")
                .foregroundStyle(.white)
        }
        .customNavigationTitle("Zoomoov")
    }
}
