import SwiftUI

struct CustomAlert: View {
    struct Data: Equatable {
        @Binding var isActive: Bool
        let title: String
        let message: String
        let buttonTitle: String
        let cancelTitle: String
        let action: EquatableAsyncVoidClosure
    }
    
    var data: Data
//    @State private var offset: CGFloat = 1000
    
    var body: some View {
        ZStack {
            if data.isActive {
                Color(.black)
                    .opacity(0.5)
                    .onTapGesture {
                        close()
                    }
                    .transition(.opacity)
                VStack {
                    Text(data.title)
                        .font(.title2)
                        .bold()
                        .padding()
                    
                    Text(data.message)
                        .font(.body)
                    
                    AsyncButton {
                        try? await data.action.closure()
                        close()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.red)
                            
                            Text(data.buttonTitle)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                        }
                        .padding()
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(alignment: .topTrailing) {
                    Button {
                        close()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                    }
                    .tint(.black)
                    .padding()
                }
                .shadow(radius: 20)
                .padding(30)
//                .offset(x: 0, y: offset)
                .transition(.flipFromBottom.combined(with: .opacity))
//                .onAppear {
//                    withAnimation(.spring()) {
//                        offset = 0
//                    }
//                }
            }
        }
        .animation(.spring(duration: 0.2), value: data.isActive)
        .ignoresSafeArea()
    }
    
    func close() {
        withAnimation(.spring()) {
//            offset = 1000
            data.isActive = false
        }
    }
}

struct CustomAlert_Previews: PreviewProvider {
    static var previews: some View {
        CustomAlert(data: .init(isActive: .constant(false),
                                title: "Delete?",
                                message: "This will delete all your data",
                                buttonTitle: "Delete",
                                cancelTitle: "Keep my account",
                                action: .init(closure: {}))
        )
    }
}
