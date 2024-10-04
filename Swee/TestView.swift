import SwiftUI

// MARK: Extensions
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func getSizeOfView(_ getSize: @escaping ((CGSize) -> Void)) -> some View {
        return self
            .background {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size
                    )
                    .onPreferenceChange(SizePreferenceKey.self) { value in
                        getSize(value)
                    }
                }
            }
    }
}

struct Carousel: View {
    @State private var contentSize: CGSize = .zero

    var body: some View {
        TabView {
            ForEach(10..<15) { index in
                VStack {
                    ContentSummaryView(
                        title: "Title \(index)",
                        subtitle: "Subtitle \(index)"
                    )
                    .getSizeOfView { contentSize = $0 }
                    .padding(.horizontal)
                }
            }
        }
        .introspect(.scrollView, on: .iOS(.v15, .v16, .v17, .v18), customize: { scrollView in
            scrollView.clipsToBounds = false
        })
        .frame(minHeight: 80, idealHeight: contentSize.height)
        .frame(maxWidth: 250)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

// MARK: App
struct ContentSummaryView: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.title)

                Text(subtitle)
                    .font(.caption)
            }

            Spacer()

            Image(systemName: "heart")
        }
        .padding()
        .background {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: SizePreferenceKey.self,
                    value: geometry.size
                )
            }
        }
        .background(.thinMaterial)
        .cornerRadius(12)
    }
}

struct ContentView: View {
    var body: some View {
        ScrollView {

            // Horizontal swipe list
            Carousel()

            // Main vertical List
            VStack(alignment: .leading) {
                ForEach(0..<10) { index in
                    ContentSummaryView(
                        title: "Title \(index)",
                        subtitle: "Subtitle \(index)"
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
}



struct ParentView: View {
    @State private var isParentVisible: Bool = true
    @State private var isChildVisible: Bool = true

    var body: some View {
        VStack {
            if isParentVisible {
                VStack {
                    Text("Parent View")
                        .padding()
                    
                    if isChildVisible {
                        ChildView()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .onDisappear {
                                print("Child View removed from hierarchy after animation")
                            }
                    }
                }
                .padding()
                .background(Color.green)
                .cornerRadius(10)
                .transition(.opacity)
            }

            Spacer()

            // Toggle button for animation
            Button(action: {
                withAnimation {
                    if isParentVisible {
                        isChildVisible = false // Hide the child first
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Add slight delay to match animation
                        withAnimation {
                            isParentVisible.toggle() // Then hide the parent
                        }
                    }
                }
            }) {
                Text(isParentVisible ? "Hide Parent View" : "Show Parent View")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct ChildView: View {
    var body: some View {
        Text("Child View")
            .padding()
            .background(Color.yellow)
            .cornerRadius(8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ParentView()
    }
}
