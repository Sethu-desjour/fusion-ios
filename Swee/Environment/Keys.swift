import SwiftUI

private struct CurrentTabKey: EnvironmentKey {
    static let defaultValue: Binding<Tabs> = .constant(.home)
}

struct BottomSheetData: Equatable {
    var view: EquatableViewContainer
    var hidden: Binding<Bool> = .constant(true)
}

struct BottomSheetContentKey: EnvironmentKey {
    static let defaultValue: Binding<BottomSheetData> = .constant(.init(view: EquatableViewContainer(view: AnyView(Text("")))))
}

private struct TabVisibilityKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(true)
}

extension EnvironmentValues {
    var currentTab: Binding<Tabs> {
        get { self[CurrentTabKey.self] }
        set { self[CurrentTabKey.self] = newValue }
    }
    
    var tabIsShown: Binding<Bool> {
        get { self[TabVisibilityKey.self] }
        set { self[TabVisibilityKey.self] = newValue }
    }
    
    var bottomSheetData: Binding<BottomSheetData> {
        get { self[BottomSheetContentKey.self] }
        set { self[BottomSheetContentKey.self] = newValue }
    }
}

extension Binding: Equatable where Value: Equatable {
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}
