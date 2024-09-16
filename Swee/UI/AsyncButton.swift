import SwiftUI

struct AsyncButton<S: View>: View {
    private let action: () async -> Void
    private let label: S

    @State private var task: Task<Void, Never>?
    @State var progressWidth: CGFloat?

    var body: some View {
        Button {
            guard task == nil else {
                return
            }
            task = Task {
                await action()
                task = nil
            }
        } label: {
            if task != nil {
                ProgressView()
                    .frame(maxWidth: progressWidth)
                    .tint(Color.white)
            } else {
                label
            }
        }
        .animation(.default, value: task)
    }

    init(progressWidth: CGFloat? = nil, action: @escaping () async -> Void, @ViewBuilder label: @escaping () -> S) {
        self.progressWidth = progressWidth
        self.action = action
        self.label = label()
    }
}
