import SwiftUI

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}

extension View {
    func onWillAppear(_ perform: @escaping () -> Void) -> some View {
        modifier(WillAppearModifier(callback: perform))
    }
    
    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        modifier(WillDisappearModifier(callback: perform))
    }
}

struct WillDisappearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content.background(UIViewLifeCycleHandler(onWillDisappear: callback))
    }
}

struct WillAppearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content.background(UIViewLifeCycleHandler(onWillAppear: callback))
    }
}

struct UIViewLifeCycleHandler: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    var onWillAppear: () -> Void = { }
    var onWillDisappear: () -> Void = { }

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> UIViewControllerType {
        context.coordinator
    }

    func updateUIViewController(
        _: UIViewControllerType,
        context _: UIViewControllerRepresentableContext<Self>
    ) { }

    func makeCoordinator() -> Self.Coordinator {
        Coordinator(onWillAppear: onWillAppear, onWillDisappear: onWillDisappear)
    }

    class Coordinator: UIViewControllerType {
        let onWillAppear: () -> Void
        let onWillDisappear: () -> Void

        init(onWillAppear: @escaping () -> Void, onWillDisappear: @escaping () -> Void) {
            self.onWillAppear = onWillAppear
            self.onWillDisappear = onWillDisappear
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            onWillAppear()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onWillDisappear()
        }
    }
}
