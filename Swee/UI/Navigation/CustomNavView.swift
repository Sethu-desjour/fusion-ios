//
//  CustomNavView.swift
//  Swee
//
//  Created by Serghei on 09.09.2024.
//

import SwiftUI

struct CustomNavView<Content: View>: View {
    let content: Content
    @State private var bottomSheetData: BottomSheetData = .init(view: Text("").equatable, hidden: .constant(true))

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                CustomNavBarContainerView {
                    content
                }
                .navigationBarHidden(true)
            }
            .onPreferenceChange(CustomNavBottomSheetData.self, perform: { value in
                self.bottomSheetData = value
            })
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitle("")
            .navigationBarHidden(true)
            BottomSheet(hide: bottomSheetData.hidden) {
                bottomSheetData.view.view
            }
        }
    }
}

#Preview {
    CustomNavView {
        Text("")
    }
}

extension UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
