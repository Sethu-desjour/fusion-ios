import SwiftUI

struct Session {
    let id: UUID
    let purchaseId: UUID
    let qrCodeImage: Image?
    let status: SessionStatus
    let startedAt: Date?
    let remainingTime: String?
    var remainingTimeMinutes: Int?
    let children: [SessionChildModel]
    
    var numberOfActiveKids: Int {
        children.filter { $0.status == .active }.count
    }
}

extension SessionModel: RawModelConvertable {
    func toLocal() -> Session {
        var image: UIImage? = nil
        if let qrCodeImage = qrCodeImage,
            let imageData = Data(base64Encoded: qrCodeImage),
            let uiImage = UIImage(data: imageData) {
            image = uiImage
        }
        return .init(id: id,
                     purchaseId: purchaseId,
                     qrCodeImage: Image(uiImage: image),
                     status: status,
                     startedAt: startedAt,
                     remainingTime: remainingTime,
                     remainingTimeMinutes: remainingTimeMinutes,
                     children: children ?? [])
    }
}
