import Foundation
import SwiftUI

struct CustomNavBarTitlePreferenceKey: PreferenceKey {
    static var defaultValue: String = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

struct CustomNavBarBackButtonHiddenPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

struct CustomNavBarHiddenPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

struct CustomNavLeadingItemPreferenceKey: PreferenceKey {
    static var defaultValue: EquatableViewContainer = EquatableViewContainer(view: AnyView(Text("")))
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

struct CustomNavTrailingItemPreferenceKey: PreferenceKey {
    static var defaultValue: EquatableViewContainer = EquatableViewContainer(view: AnyView(Text("")))
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

struct CustomNavBottomSheetData: PreferenceKey {
    static var defaultValue: BottomSheetData = .init(view: Text("").equatable, hidden: .constant(true))
    
    static func reduce(value: inout BottomSheetData, nextValue: () -> BottomSheetData) {
        value = nextValue()
    }
}

struct CustomAlertData: PreferenceKey {
    static var defaultValue: CustomAlert.Data = .init(isActive: .constant(false),
                                                      title: "",
                                                      message: "",
                                                      buttonTitle: "",
                                                      cancelTitle: "",
                                                      action: .init(closure: {}))
    
    static func reduce(value: inout CustomAlert.Data, nextValue: () -> CustomAlert.Data) {
        value = nextValue()
    }
}

extension View {
    func customNavigationTitle(_ title: String) -> some View {
        preference(key: CustomNavBarTitlePreferenceKey.self, value: title)
    }
    
    func customNavigationBackButtonHidden(_ hidden: Bool) -> some View {
        preference(key: CustomNavBarBackButtonHiddenPreferenceKey.self, value: hidden)
    }
    
    func customNavBarHidden(_ hidden: Bool) -> some View {
        preference(key: CustomNavBarHiddenPreferenceKey.self, value: hidden)
    }
    
    func customNavLeadingItem(@ViewBuilder _ content: () -> some View) -> some View {
        preference(key: CustomNavLeadingItemPreferenceKey.self, value: EquatableViewContainer(view: AnyView(content())))
    }
    
    func customNavTrailingItem(@ViewBuilder _ content: () -> some View) -> some View {
        preference(key: CustomNavTrailingItemPreferenceKey.self, value: EquatableViewContainer(view: AnyView(content())))
    }
    
    func customBottomSheet(hidden: Binding<Bool>, @ViewBuilder _ content: () -> some View) -> some View {
        preference(key: CustomNavBottomSheetData.self, value: BottomSheetData(view: content().equatable, hidden: hidden))
    }
    
//    func customAlert(isActive: Binding<Bool>,
//                     title: String,
//                     message: String,
//                     buttonTitle: String,
//                     cancelTitle: String,
//                     action: @escaping () async throws -> Void) -> some View {
//        preference(key: CustomAlertData.self, value: .init(isActive: isActive, title: title, message: message, buttonTitle: buttonTitle, cancelTitle: cancelTitle, action: .init(closure: action)))
//    }
    
    func customAlert(data: CustomAlert.Data) -> some View {
        preference(key: CustomAlertData.self, value: data)
    }
}


struct EquatableViewContainer: Equatable {
    let id = UUID().uuidString
    let view: AnyView
    
    static func == (lhs: EquatableViewContainer, rhs: EquatableViewContainer) -> Bool {
        return lhs.id == rhs.id
    }
}

struct EquatableAsyncVoidClosure: Equatable {
    let id = UUID().uuidString
    let closure: () async throws -> Void
    
    static func == (lhs: EquatableAsyncVoidClosure, rhs: EquatableAsyncVoidClosure) -> Bool {
        return lhs.id == rhs.id
    }
}
