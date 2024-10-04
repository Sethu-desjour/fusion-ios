import SwiftUI

struct Redemption {
    let id: UUID
    let purchaseId: UUID
    let storeId: UUID?
    let qrCodeImage: Image?
    let status: RedemptionStatus
    let createdAt: Date
}

extension RedemptionModel: RawModelConvertable {
    func toLocal() -> Redemption {
        let imageData = Data(base64Encoded: qrCodeImage!)
        let image = UIImage(data: imageData!)
        return .init(id: id,
                     purchaseId: purchaseId,
                     storeId: redemptionStoreId,
                     qrCodeImage: Image(uiImage: image),
                     status: status,
                     createdAt: createdAt)
    }
}
