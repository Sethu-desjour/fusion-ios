import SwiftUI

struct RedemptionDetail: Hashable {
    let id: UUID
    let merchantName: String
    let bgColors: [Color]
    let productName: String
    let type: ProductType
    let storeName: String
    let value: Int
    let status: RedemptionStatus
    let createdAt: Date
}

extension RedemptionDetailModel: RawModelConvertable {
    func toLocal() -> RedemptionDetail {
        var colors: [Color] = [.gray]
        if let bgColors = merchantBackgroundColors {
            colors = bgColors.map { Color(hex: $0) }
        }
        
        return .init(id: id,
                     merchantName: merchantName,
                     bgColors: colors,
                     productName: productName,
                     type: productType,
                     storeName: storeName,
                     value: value,
                     status: status,
                     createdAt: createdAt)
    }
}
