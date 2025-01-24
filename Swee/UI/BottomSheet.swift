import SwiftUI

struct BottomSheet<Content: View>: View {
    @Binding var hide: Bool
    var shouldDismissOnBackgroundTap: Bool = true
    @ViewBuilder let content: Content
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if !hide {
                Button {
                    if shouldDismissOnBackgroundTap {
                        hide.toggle()
                    }
                } label: {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                }
                .buttonStyle(EmptyStyle())
                .transition(.opacity)
                VStack {
                    content
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding([.leading, .trailing], 16)
                .padding([.top, .bottom], 33)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .layoutPriority(1)
                .frame(maxWidth: .infinity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hide)
        .ignoresSafeArea()
    }
}
