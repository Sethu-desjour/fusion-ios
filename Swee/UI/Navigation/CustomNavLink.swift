import SwiftUI

struct CustomNavLink<Label: View, Destination: View>: View {
    
    let destination: Destination
    let label: Label
    @State private var legacyNav: Bool
    @Binding var isActive: Bool
    
    init(destination: Destination, @ViewBuilder label: () -> Label) {
        self._isActive = Binding<Bool>.init(get: {
            return false
        }, set: { _ in
            
        })
        self.legacyNav = false
        self.destination = destination
        self.label = label()
    }
    
    init(isActive: Binding<Bool>, destination: Destination, @ViewBuilder label: () -> Label = { EmptyView() }) {
        self._isActive = isActive
        self.legacyNav = true
        self.destination = destination
        self.label = label()
    }
    
    var body: some View {
        if legacyNav {
            NavigationLink(isActive: $isActive) {
                CustomNavBarContainerView(content: {
                    destination
                })
                    .navigationBarHidden(true)
            } label: {
                label
            }
        } else {
            NavigationLink() {
                CustomNavBarContainerView(content: {
                    destination
                })
                    .navigationBarHidden(true)
            } label: {
                label
            }
        }
    }
}

//#Preview {
//    CustomNavLink()
//}
