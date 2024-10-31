import SwiftUI

struct Session: Equatable {
    let id: UUID
    let merchantId: UUID?
    let merchantName: String?
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
                     merchantId: merchantId,
                     merchantName: merchantName,
                     qrCodeImage: Image(uiImage: image),
                     status: status,
                     startedAt: startedAt,
                     remainingTime: remainingTime,
                     remainingTimeMinutes: remainingTimeMinutes,
                     children: children ?? [])
    }
}
