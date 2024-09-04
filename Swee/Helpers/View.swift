import SwiftUI

extension View {
    func addInnerShadow() -> some View {
        if #available(iOS 16.0, *) {
            return self.foregroundStyle(
                Color.white.shadow(
                    .inner(color: .black.opacity(0.25), radius: 1, x: 0, y: 1)
                )
            )
        } else {
            return self.foregroundStyle(.white)
        }
    }
}

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}

extension View {
    func onWillAppear(_ perform: @escaping () -> Void) -> some View {
        modifier(WillAppearModifier(callback: perform))
    }
    
    func onDidAppear(_ perform: @escaping () -> Void) -> some View {
        modifier(DidAppearModifier(callback: perform))
    }
    
    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        modifier(WillDisappearModifier(callback: perform))
    }
    
    func onDidDisappear(_ perform: @escaping () -> Void) -> some View {
        modifier(DidDisappearModifier(callback: perform))
    }
    
    func onDidLoad(_ perform: @escaping () -> Void) -> some View {
        modifier(DidLoadModifier(callback: perform))
    }
}

struct WillDisappearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content.background(UIViewLifeCycleHandler(onWillDisappear: callback))
    }
}

struct DidDisappearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content.background(UIViewLifeCycleHandler(onDidDisappear: callback))
    }
}

struct WillAppearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content.background(UIViewLifeCycleHandler(onWillAppear: callback))
    }
}

struct DidAppearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content.background(UIViewLifeCycleHandler(onDidAppear: callback))
    }
}

struct DidLoadModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content.background(UIViewLifeCycleHandler(onDidLoad: callback))
    }
}

struct UIViewLifeCycleHandler: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    var onWillAppear: () -> Void = { }
    var onDidAppear: () -> Void = { }
    var onWillDisappear: () -> Void = { }
    var onDidDisappear: () -> Void = { }
    var onDidLoad: () -> Void = { }

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> UIViewControllerType {
        context.coordinator
    }

    func updateUIViewController(
        _: UIViewControllerType,
        context _: UIViewControllerRepresentableContext<Self>
    ) { }

    func makeCoordinator() -> Self.Coordinator {
        Coordinator(onWillAppear: onWillAppear,
                    onDidAppear: onDidAppear,
                    onWillDisappear: onWillDisappear,
                    onDidDisappear: onDidDisappear,
                    onDidLoad: onDidLoad)
    }

    class Coordinator: UIViewControllerType {
        let onWillAppear: () -> Void
        let onDidAppear: () -> Void
        let onWillDisappear: () -> Void
        let onDidDisappear: () -> Void
        let onDidLoad: () -> Void

        init(onWillAppear: @escaping () -> Void, onDidAppear: @escaping () -> Void,  onWillDisappear: @escaping () -> Void, onDidDisappear: @escaping () -> Void, onDidLoad: @escaping () -> Void) {
            self.onWillAppear = onWillAppear
            self.onDidAppear = onDidAppear
            self.onWillDisappear = onWillDisappear
            self.onDidDisappear = onDidDisappear
            self.onDidLoad = onDidLoad
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
        
        override func viewDidLoad() {
            super.viewDidLoad()
            onDidLoad()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            onDidAppear()
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            onDidDisappear()
        }
    }
}
