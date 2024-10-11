import SwiftUI

struct Child: Equatable, Hashable {
    var id: UUID?
    var name: String
    var dob: Date?
    
    var isValid: Bool {
        !name.isEmpty && dob != nil
    }
}

extension ChildModel: RawModelConvertable {
    func toLocal() -> Child {
        .init(id: id, name: name, dob: dateOfBirth)
    }
}
