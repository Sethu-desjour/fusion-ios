import SwiftUI

struct ContentErrorView: View {
    let retry: () async -> Void
    
    var body: some View {
        VStack {
            Image("refresh")
            Text("Unable to load content")
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundStyle(Color.text.black80)
            AsyncButton(progressTint: .black) {
                await retry()
            } label: {
                Text("Retry")
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundStyle(Color.primary.brand)
            }
            .padding(.top, 12)
        }
        .padding(.vertical, 54)
        .frame(maxWidth: .infinity)
        .background(Color.text.black10)
    }
}

#Preview {
    ContentErrorView {}
}
