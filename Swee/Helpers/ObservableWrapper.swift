import Combine

class ObservableWrapper<T, U>: ObservableObject {
    @Published var prop: T
    
    init(_ propToWrap: T) {
        self.prop = propToWrap
    }
}
