import SwiftUI

struct Redemption: Hashable {
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
    let id: UUID
    let purchaseId: UUID
    let storeId: UUID?
    let qrCodeImage: Image?
    let value: Int
    let status: RedemptionStatus
    let storeName: String?
    let createdAt: Date
}

extension RedemptionModel: RawModelConvertable {
    func toLocal() -> Redemption {
        var image: UIImage? = nil
        if let qrCodeImage = qrCodeImage, 
            let imageData = Data(base64Encoded: qrCodeImage),
            let uiImage = UIImage(data: imageData) {
            image = uiImage
        }
        return .init(id: id,
                     purchaseId: purchaseId,
                     storeId: redemptionStoreId,
                     qrCodeImage: Image(uiImage: image),
                     value: value,
                     status: status,
                     storeName: redemptionStoreName,
                     createdAt: createdAt)
    }
}
