import SwiftUI

struct BottomSheet<Content: View>: View {
    @Binding var hide: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if !hide {
                Button {
                    hide.toggle()
                } label: {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
//                        .animation(.easeInOut(duration: 0.2), value: hide)
                }
            }
            VStack {
                content
            }
            .padding([.leading, .trailing], 16)
            .padding([.top, .bottom], 33)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .layoutPriority(1)
            .frame(height: hide ? 0 : nil, alignment: .top)
            .hidden(hide)
        }
        .animation(.easeInOut(duration: 0.2), value: hide)
        .ignoresSafeArea()
    }
}
