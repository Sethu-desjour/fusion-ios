import SwiftUI

struct ContentOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct ObservableScrollView<Content: View>: View {
    let content: Content
    let axis: Axis.Set
    let showIndicators: Bool
    @Binding var contentOffset: CGFloat

    init(_ axis: Axis.Set = .vertical, 
         showIndicators: Bool = true,
         contentOffset: Binding<CGFloat>, 
         @ViewBuilder content: () -> Content) {
        self._contentOffset = contentOffset
        self.content = content()
        self.axis = axis
        self.showIndicators = showIndicators
    }

    var body: some View {
        ScrollView(axis, showsIndicators: showIndicators) {
            content
                .background {
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ContentOffsetKey.self, value: geometry.frame(in: .named("scrollView")).minX)
                    }
                }
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ContentOffsetKey.self) { value in
            self.contentOffset = value
        }
    }
}
