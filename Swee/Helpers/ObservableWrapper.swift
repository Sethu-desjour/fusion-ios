import Combine

class ObservableWrapper<T>: ObservableObject {
    @Published var prop: T
    
    init(_ propToWrap: T) {
        self.prop = propToWrap
    }
}
