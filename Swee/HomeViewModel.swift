import SwiftUI
import Combine

// ViewModel that handles data fetching
class HomeViewModel: ObservableObject {
    enum SectionContent {
        case bannerCarousel([Banner])
        case packages([Package])
        case merchants([Merchant])
        case bannerStatic
    }
    
    struct Section {
        var title: String?
        let content: SectionContent
    }
    
    var api: API = API()
    @State private var loadedData = false
    @Published var sections: [Section] = []
    
    func fetch() {
        guard !loadedData else {
            return
        }
        Task {
            do {
                let sectionsModels = try await self.api.homeSections()
                loadedData = true
                print("sections ======", sectionsModels)
                let sections: [Section] = sectionsModels.map { model in
                    switch model.type {
                    case .bannerCarousel:
                            .init(title: model.title, content: .bannerCarousel(model.banners.toBanners()))
                    case .packageCarousel:
                            .init(title: model.title, content: .packages(model.packages.toPackages()))
                    case .merchantList:
                            .init(title: model.title, content: .merchants(model.merchants.toMerchants()))
                    case .bannerStatic:
                        // @todo figure out what this is
                            .init(content: .bannerStatic)
                    }
                }
                await MainActor.run {
                    self.sections = sections
                }
            } catch {
                // @todo parse error and show error screen
            }
        }
    }
}

fileprivate extension Optional where Wrapped == [BannerModel] {
    func toBanners() -> [Banner] {
        switch self {
        case .none:
            return []
        case .some(let banners):
            return banners.map { $0.toBanner() }
        }
    }
}


fileprivate extension Optional where Wrapped == [PackageModel] {
    func toPackages() -> [Package] {
        switch self {
        case .none:
            return []
        case .some(let banners):
            return banners.map { $0.toPackage() }
        }
    }
}


fileprivate extension Optional where Wrapped == [MerchantModel] {
    func toMerchants() -> [Merchant] {
        switch self {
        case .none:
            return []
        case .some(let banners):
            return banners.map { $0.toMerchant() }
        }
    }
}

fileprivate extension BannerModel {
    func toBanner() -> Banner {
        .init(title: name,
              description: description  ?? "",
              buttonTitle: ctaText,
              backgroundImage: .init("banner-bg-1"),
              badgeImage: .init("badge-1"))
    }
}

fileprivate extension PackageModel {
    func toPackage() -> Package {
        .init(merchant: "Zoomoov",
              image: .init("offer-1"),
              title: name, 
              description: description ?? "",
              price: priceCents.toPrice(),
              originalPrice: originalPriceCents.toPrice())
    }
}

fileprivate extension MerchantModel {
    func toMerchant() -> Merchant {
        .init(name: name,
              bgImage: Image("explore-bg-1"),
              storeImage: Image("merchant-bg"))
    }
}

fileprivate extension Optional where Wrapped == Int {
    func toPrice() -> Double? {
        switch self {
        case .none:
            return nil
        case .some(let price):
            return price.toPrice()
        }
    }
}

fileprivate extension Int {
    func toPrice() -> Double {
        return Double(self / 100)
    }
}
