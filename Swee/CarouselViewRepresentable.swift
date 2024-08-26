import SwiftUI


struct BannersView: View {
    @Binding var bannerModels: [BannerModel]
    @Binding var page: Int
    @State private var coordinator = CarouselCoordinator()
    
    var body: some View {
        CarouselViewRepresentable(bannerModels: $bannerModels, page: $page, coordinator: coordinator)
    }
    
    public func onPageChange(_ closure: @escaping (_ newValue: Int) -> Void) -> Self {
        coordinator.onPageChange = closure
        return self
    }
}

public class CarouselCoordinator: NSObject, CarouselUpdateDelegate {
    var onPageChange: ((Int) -> Void)?
    
    public func carouselView(movedToPage page: Int) {
        onPageChange?(page)
    }
}

public struct CarouselViewRepresentable: UIViewControllerRepresentable {
    @Binding var bannerModels: [BannerModel]
    @Binding var page: Int
    @State private var coordinator: CarouselCoordinator
    
    init(bannerModels: Binding<[BannerModel]>, page: Binding<Int>, coordinator: CarouselCoordinator) {
        self._bannerModels = bannerModels
        self._page = page
        self.coordinator = coordinator
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        
        let children = bannerModels.map { model in
            return UIHostingController(rootView: Banner(banner: .init(title: model.title,
                                                                      description: model.description,
                                                                      buttonTitle: model.buttonTitle,
                                                                      backgroundImage: model.backgroundImage,
                                                                      badgeImage: model.badgeImage)))
        }
        
        let carouselViewController = CarouselViewController(viewControllers: children)
        let carouselView = CarouselView(horizontalPadding: 80)
        carouselView.dataSource = carouselViewController
        carouselView.delegate = carouselViewController
        carouselView.updateDelegate = context.coordinator
        carouselViewController.view = carouselView
        
        return carouselViewController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let carouselVC = uiViewController as! CarouselViewController
        carouselVC.carouselView.gotoPage(at: page)
    }
    
    public func makeCoordinator() -> CarouselCoordinator {
        return coordinator
    }
}

//#Preview {
//    Carousel()
//}
