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
    @State private var alertData: CustomAlertData = .init(isActive: .constant(false),
                                                           title: "",
                                                           message: "",
                                                           buttonTitle: "", 
                                                           cancelTitle: "",
                                                           action: .init(closure: {}))

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
            .onPreferenceChange(CustomAlertData.self, perform: { value in
                self.alertData = value
            })
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitle("")
            .navigationBarHidden(true)
            BottomSheet(hide: bottomSheetData.hidden) {
                bottomSheetData.view.view
            }
            CustomAlert(isActive: alertData.$isActive, data: .init(title: alertData.title,
                                                                  message: alertData.message,
                                                                  buttonTitle: alertData.buttonTitle,
                                                                  cancelTitle: alertData.cancelTitle, 
                                                                  action: alertData.action))
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
